import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart';
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

  final _stt = SpeechToText();
  bool _sttAvailable = false;
  bool _isListening  = false;

  @override
  void initState() {
    super.initState();
    _initStt();
  }

  Future<void> _initStt() async {
    final available = await _stt.initialize(
      onError: (_) => setState(() => _isListening = false),
      onStatus: (status) {
        if (status == SpeechToText.doneStatus ||
            status == SpeechToText.notListeningStatus) {
          setState(() => _isListening = false);
        }
      },
    );
    if (mounted) setState(() => _sttAvailable = available);
  }

  Future<void> _toggleVoice() async {
    if (!_sttAvailable) return;
    if (_isListening) {
      await _stt.stop();
      setState(() => _isListening = false);
      return;
    }
    final hasSpeech = await _stt.initialize();
    if (!hasSpeech || !mounted) return;

    setState(() => _isListening = true);
    _stt.listen(
      localeId: 'es_ES',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          _controller.text = result.recognizedWords;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _stt.stop();
    _controller.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _focusNode.unfocus();
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
                      userRole: userRole,
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
              sttAvailable: _sttAvailable,
              isListening: _isListening,
              onVoice: _toggleVoice,
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
    final title = ref.watch(aiChatProvider.select((s) => s.conversationTitle));

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
                Text(
                  title != null && title.isNotEmpty ? title : 'Captus IA',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
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
          if (userRole == 'teacher')
            IconButton(
              icon: const Icon(Icons.build_circle_outlined,
                  color: AppColors.textSecondary),
              tooltip: 'Herramientas IA',
              onPressed: () => context.push('/ai/teacher-tools'),
            )
          else
            IconButton(
              icon: const Icon(Icons.menu_book_rounded,
                  color: AppColors.textSecondary),
              tooltip: 'Modo Estudio',
              onPressed: () => context.push('/ai/study'),
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
          // Reasoning steps (collapsible)
          if (!isUser && message.steps.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 34, top: 4),
              child: _ThinkingSteps(steps: message.steps),
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
  final String userRole;

  const _EmptyState({
    required this.suggestions,
    required this.onSuggestion,
    required this.userRole,
  });

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
          const SizedBox(height: 8),
          // ── Mode Study / Teacher Tools shortcut ─────────────────────────
          Builder(
            builder: (context) => InkWell(
              onTap: () => context.push(
                userRole == 'teacher' ? '/ai/teacher-tools' : '/ai/study',
              ),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    Icon(
                      userRole == 'teacher'
                          ? Icons.build_circle_outlined
                          : Icons.menu_book_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        userRole == 'teacher'
                            ? 'Herramientas IA Docente'
                            : 'Modo Estudio IA',
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),
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

// ── Thinking steps (collapsible) ─────────────────────────────────────────────

class _ThinkingSteps extends StatefulWidget {
  final List<AiStep> steps;
  const _ThinkingSteps({required this.steps});

  @override
  State<_ThinkingSteps> createState() => _ThinkingStepsState();
}

class _ThinkingStepsState extends State<_ThinkingSteps> {
  bool _expanded = false;

  static const _toolIcons = <String, IconData>{
    'create_task':            Icons.add_task_rounded,
    'complete_task':          Icons.task_alt_rounded,
    'update_task':            Icons.edit_note_rounded,
    'delete_task':            Icons.delete_outline_rounded,
    'list_tasks':             Icons.checklist_rounded,
    'create_note':            Icons.note_add_outlined,
    'update_note':            Icons.edit_outlined,
    'delete_note':            Icons.delete_outline_rounded,
    'list_notes':             Icons.notes_rounded,
    'create_event':           Icons.event_rounded,
    'update_event':           Icons.edit_calendar_rounded,
    'delete_event':           Icons.event_busy_rounded,
    'list_events':            Icons.calendar_month_rounded,
    'get_teacher_courses':    Icons.school_rounded,
    'get_course_analytics':   Icons.bar_chart_rounded,
    'get_at_risk_students':   Icons.warning_amber_rounded,
    'generate_grade_report':  Icons.grading_rounded,
    'generate_question_bank': Icons.quiz_outlined,
    'generate_rubric':        Icons.rule_rounded,
    'study_document':         Icons.menu_book_rounded,
  };

  IconData _iconFor(String name) =>
      _toolIcons[name] ?? Icons.settings_suggest_rounded;

  String _labelFor(String name) =>
      name.replaceAll('_', ' ').replaceFirstMapped(
          RegExp(r'^.'), (m) => m.group(0)!.toUpperCase());

  @override
  Widget build(BuildContext context) {
    final count = widget.steps.length;
    final allOk = widget.steps.every((s) => s.success);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        alignment: Alignment.topLeft,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withAlpha(35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      allOk ? Icons.psychology_rounded : Icons.psychology_alt_rounded,
                      size: 14,
                      color: allOk ? AppColors.primary : Colors.orange,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$count ${count == 1 ? 'paso' : 'pasos'} de razonamiento',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
              // Step list (visible when expanded)
              if (_expanded) ...[
                Divider(
                    height: 1,
                    color: AppColors.primary.withAlpha(30),
                    indent: 10,
                    endIndent: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.steps.asMap().entries.map((e) {
                      final idx  = e.key;
                      final step = e.value;
                      return Padding(
                        padding: EdgeInsets.only(top: idx == 0 ? 0 : 5),
                        child: Row(
                          children: [
                            Icon(
                              step.success
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              size: 12,
                              color: step.success ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 5),
                            Icon(_iconFor(step.name),
                                size: 13, color: AppColors.textSecondary),
                            const SizedBox(width: 5),
                            Text(
                              _labelFor(step.name),
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final bool sttAvailable;
  final bool isListening;
  final VoidCallback onSend;
  final VoidCallback onStop;
  final VoidCallback onVoice;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onSend,
    required this.onStop,
    required this.sttAvailable,
    required this.isListening,
    required this.onVoice,
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
          const SizedBox(width: 6),
          // Mic button (voice input)
          if (sttAvailable)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: isListening
                    ? Colors.red.withAlpha(25)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isListening ? Colors.red : AppColors.border,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  isListening ? Icons.stop_rounded : Icons.mic_rounded,
                  color: isListening ? Colors.red : AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: onVoice,
                padding: EdgeInsets.zero,
              ),
            ),
          const SizedBox(width: 6),
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
