import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/ai_chat_provider.dart';
import '../../../core/providers/auth_provider.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focusNode  = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _focusNode.unfocus();          // hide keyboard on send
    ref.read(aiChatProvider.notifier).send(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Quick suggestions per role ────────────────────────────────────────────

  List<String> _suggestions(String role) {
    if (role == 'teacher') {
      return [
        '¿Cuántos estudiantes tengo matriculados?',
        'Genera un banco de preguntas',
        'Muestra estudiantes en riesgo',
      ];
    }
    return [
      '¿Qué tareas tengo pendientes?',
      'Crea un recordatorio para mañana',
      '¿Qué eventos tengo esta semana?',
    ];
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final chatState   = ref.watch(aiChatProvider);
    final authAsync   = ref.watch(authProvider);
    final userRole    = authAsync.asData?.value.role ?? 'student';
    final suggestions = _suggestions(userRole);

    // Auto-scroll when messages change
    ref.listen(aiChatProvider, (prev, next) {
      if ((prev?.messages.length ?? 0) != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(userRole: userRole),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: chatState.messages.isEmpty
                  ? _EmptyState(
                      suggestions: suggestions,
                      onSuggestion: (s) {
                        ref.read(aiChatProvider.notifier).send(s);
                        _scrollToBottom();
                      },
                    )
                  : _MessageList(
                      scrollCtrl: _scrollCtrl,
                      messages: chatState.messages,
                      isLoading: chatState.isLoading,
                      suggestions: suggestions,
                      onSuggestion: (s) {
                        ref.read(aiChatProvider.notifier).send(s);
                        _scrollToBottom();
                      },
                    ),
            ),
            _InputBar(
              controller: _controller,
              focusNode: _focusNode,
              isLoading: chatState.isLoading,
              onSend: _send,
              onStop: () => ref.read(aiChatProvider.notifier).stop(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  final String userRole;
  const _Header({required this.userRole});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Captus IA',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.textPrimary)),
                Text(
                  userRole == 'teacher'
                      ? 'Asistente docente · Gemini'
                      : 'Asistente académico · Gemini',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded,
                color: AppColors.textSecondary),
            tooltip: 'Historial',
            onPressed: () => context.push('/ai/history'),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded,
                color: AppColors.textSecondary),
            tooltip: 'Configuración',
            onPressed: () => context.push('/ai/settings'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                color: AppColors.textSecondary, size: 20),
            onSelected: (v) {
              if (v == 'clear') {
                ref.read(aiChatProvider.notifier).clear();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.delete_sweep_outlined),
                  title: Text('Nueva conversación'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Message list ──────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  final ScrollController scrollCtrl;
  final List<ChatMessage> messages;
  final bool isLoading;
  final List<String> suggestions;
  final void Function(String) onSuggestion;

  const _MessageList({
    required this.scrollCtrl,
    required this.messages,
    required this.isLoading,
    required this.suggestions,
    required this.onSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = messages.length + (isLoading ? 1 : 0);

    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: itemCount,
      itemBuilder: (_, i) {
        if (i == messages.length) return const _TypingBubble();
        final msg = messages[i];
        final isLast = i == messages.length - 1;
        return _MessageBubble(
          message: msg,
          showSuggestions: isLast && !msg.isUser && !isLoading,
          suggestions: suggestions,
          onSuggestion: onSuggestion,
        );
      },
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showSuggestions;
  final List<String> suggestions;
  final void Function(String) onSuggestion;

  const _MessageBubble({
    required this.message,
    required this.showSuggestions,
    required this.suggestions,
    required this.onSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  height: 28,
                  width: 28,
                  margin: const EdgeInsets.only(right: 6, bottom: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      size: 14, color: AppColors.primary),
                ),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.78,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: AppColors.border),
                  ),
                  child: isUser
                      ? SelectableText(
                          message.text,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white,
                            height: 1.45,
                          ),
                        )
                      : _MarkdownMessage(text: message.text),
                ),
              ),
            ],
          ),
          // Action chip (tool was invoked)
          if (!isUser && message.actionPerformed != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 34),
              child: ActionChip(
                avatar: const Icon(Icons.check_circle_outline,
                    size: 14, color: AppColors.primary),
                label: Text(
                  _actionLabel(message.actionPerformed!),
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.primary),
                ),
                backgroundColor: AppColors.primary.withAlpha(12),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                onPressed: null,
              ),
            ),
          ],
          // Quick suggestions after last AI message
          if (showSuggestions) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: suggestions
                  .map((s) => _SuggestionChip(
                        label: s,
                        onTap: () => onSuggestion(s),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _actionLabel(String action) {
    const labels = {
      'create_task':      'Tarea creada',
      'complete_task':    'Tarea completada',
      'update_task':      'Tarea actualizada',
      'delete_task':      'Tarea eliminada',
      'list_tasks':       'Tareas consultadas',
      'create_note':      'Nota guardada',
      'update_note':      'Nota actualizada',
      'delete_note':      'Nota eliminada',
      'list_notes':       'Notas consultadas',
      'create_event':     'Evento creado',
      'update_event':     'Evento actualizado',
      'delete_event':     'Evento eliminado',
      'list_events':      'Eventos consultados',
      'get_teacher_courses':    'Cursos consultados',
      'get_course_analytics':   'Analítica de curso',
      'get_at_risk_students':   'Riesgo académico',
      'generate_grade_report':  'Reporte de notas',
      'generate_question_bank': 'Banco de preguntas',
      'generate_rubric':        'Rúbrica generada',
      'study_document':         'Material de estudio',
    };
    return labels[action] ?? action.replaceAll('_', ' ');
  }
}

// ── Markdown message (AI only) ────────────────────────────────────────────────

class _MarkdownMessage extends StatelessWidget {
  final String text;
  const _MarkdownMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.inter(
      fontSize: 14,
      color: AppColors.textPrimary,
      height: 1.5,
    );

    return MarkdownBody(
      data: text,
      selectable: true,
      softLineBreak: true,
      styleSheet: MarkdownStyleSheet(
        // Paragraph
        p: baseStyle,
        // Bold
        strong: baseStyle.copyWith(fontWeight: FontWeight.w700),
        // Italic
        em: baseStyle.copyWith(fontStyle: FontStyle.italic),
        // Headings
        h1: GoogleFonts.inter(
            fontSize: 17, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary, height: 1.4),
        h2: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary, height: 1.4),
        h3: GoogleFonts.inter(
            fontSize: 14, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary, height: 1.4),
        // Inline code
        code: GoogleFonts.sourceCodePro(
          fontSize: 13,
          color: AppColors.primary,
          backgroundColor: AppColors.primary.withAlpha(15),
        ),
        // Code block
        codeblockDecoration: BoxDecoration(
          color: AppColors.primary.withAlpha(10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withAlpha(40)),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        // Blockquote
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: AppColors.primary, width: 3),
          ),
          color: AppColors.primary.withAlpha(8),
        ),
        blockquotePadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 6),
        // Lists
        listBullet: baseStyle,
        listBulletPadding: const EdgeInsets.only(right: 6),
        listIndent: 16,
        // Horizontal rule
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        // Spacing
        pPadding: const EdgeInsets.only(bottom: 4),
        h1Padding: const EdgeInsets.only(bottom: 6, top: 4),
        h2Padding: const EdgeInsets.only(bottom: 4, top: 4),
        h3Padding: const EdgeInsets.only(bottom: 2, top: 4),
      ),
    );
  }
}

// ── Typing bubble ─────────────────────────────────────────────────────────────

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            height: 28,
            width: 28,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                size: 14, color: AppColors.primary),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final delay = i * 0.33;
                  final opacity = (((_anim.value - delay) % 1.0 + 1.0) % 1.0);
                  return Container(
                    margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.primary
                          .withAlpha((opacity * 200 + 55).round()),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state with suggestions ──────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String) onSuggestion;

  const _EmptyState({required this.suggestions, required this.onSuggestion});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text('¿En qué puedo ayudarte?',
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(
            'Puedo gestionar tus tareas, eventos, notas y responderte preguntas académicas.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 28),
          ...suggestions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => onSuggestion(s),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(s,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.textPrimary)),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 14, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

// ── Suggestion chip ───────────────────────────────────────────────────────────

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withAlpha(50)),
        ),
        child: Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w500)),
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final VoidCallback onSend;
  final VoidCallback onStop;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onSend,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.enter &&
                    !HardwareKeyboard.instance.isShiftPressed) {
                  onSend();
                }
              },
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje…',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: isLoading
                ? _StopButton(key: const ValueKey('stop'), onStop: onStop)
                : _SendButton(key: const ValueKey('send'), onSend: onSend),
          ),
        ],
      ),
    );
  }
}

// ── Send / Stop action buttons ────────────────────────────────────────────────

class _SendButton extends StatelessWidget {
  final VoidCallback onSend;
  const _SendButton({super.key, required this.onSend});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 44,
        width: 44,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            onPressed: onSend,
            padding: EdgeInsets.zero,
          ),
        ),
      );
}

class _StopButton extends StatelessWidget {
  final VoidCallback onStop;
  const _StopButton({super.key, required this.onStop});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 44,
        width: 44,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: IconButton(
            icon: Icon(Icons.stop_rounded,
                color: Colors.red.shade600, size: 20),
            onPressed: onStop,
            padding: EdgeInsets.zero,
            tooltip: 'Detener',
          ),
        ),
      );
}
