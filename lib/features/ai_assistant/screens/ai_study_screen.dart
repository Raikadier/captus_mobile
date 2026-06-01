import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/services/api_client.dart';
import '../../../shared/widgets/captus_pressable.dart';

enum _StudyMode { flashcards, quiz, resumen, mapaConceptual }

extension _StudyModeExt on _StudyMode {
  String get label {
    switch (this) {
      case _StudyMode.flashcards:
        return 'Flashcards';
      case _StudyMode.quiz:
        return 'Quiz';
      case _StudyMode.resumen:
        return 'Resumen';
      case _StudyMode.mapaConceptual:
        return 'Mapa conceptual';
    }
  }

  String get emoji {
    switch (this) {
      case _StudyMode.flashcards:
        return '📇';
      case _StudyMode.quiz:
        return '❓';
      case _StudyMode.resumen:
        return '📝';
      case _StudyMode.mapaConceptual:
        return '🗺️';
    }
  }

  String get apiLabel {
    switch (this) {
      case _StudyMode.flashcards:
        return 'flashcards';
      case _StudyMode.quiz:
        return 'un quiz';
      case _StudyMode.resumen:
        return 'un resumen';
      case _StudyMode.mapaConceptual:
        return 'un mapa conceptual';
    }
  }
}

// AiStudyScreen calls the AI backend directly without going through
// aiChatProvider — study sessions are self-contained and do not bleed
// into the user's main chat history.
class AiStudyScreen extends StatefulWidget {
  const AiStudyScreen({super.key});

  @override
  State<AiStudyScreen> createState() => _AiStudyScreenState();
}

class _AiStudyScreenState extends State<AiStudyScreen> {
  final _contentCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  _StudyMode _selectedMode = _StudyMode.resumen;
  bool _generated = false;
  String? _result;
  bool _isLoading = false;
  CancelToken? _cancelToken;

  static final _receiveOptions =
      Options(receiveTimeout: const Duration(seconds: 90));

  @override
  void dispose() {
    _cancelToken?.cancel('Screen disposed');
    _contentCtrl.dispose();
    _subjectCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pega el contenido del documento primero')),
      );
      return;
    }

    final subject = _subjectCtrl.text.trim();
    final materia = subject.isNotEmpty ? ' sobre $subject' : '';
    final msg =
        'Genera ${_selectedMode.apiLabel} del siguiente documento$materia:\n\n$content';

    _cancelToken = CancelToken();

    setState(() {
      _isLoading = true;
      _generated = false;
      _result = null;
    });

    try {
      // Direct call to /ai/chat — no conversationId, so this creates an
      // isolated one-shot conversation that never touches the user's chat history.
      final res = await ApiClient.instance.post<Map<String, dynamic>>(
        '/ai/chat',
        data: {'message': msg},
        options: _receiveOptions,
        cancelToken: _cancelToken,
      );

      final body = res.data ?? <String, dynamic>{};
      final reply = body['result'] as String? ?? 'Sin respuesta.';

      if (mounted) {
        setState(() {
          _result = reply;
          _generated = true;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return;
      if (mounted) {
        setState(() {
          _isLoading = false;
          _result = 'No pude conectar con el asistente. Intenta de nuevo.';
          _generated = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _result = 'Error inesperado. Intenta de nuevo.';
          _generated = true;
        });
      }
    }
  }

  void _reset() {
    _cancelToken?.cancel('Nueva sesión');
    setState(() {
      _contentCtrl.clear();
      _subjectCtrl.clear();
      _generated = false;
      _result = null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      restorationId: 'ai_study_screen',
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Modo Estudio IA',
          style: tt.headlineMedium,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header banner ────────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(AppSpacing.s4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(AppAlpha.a10),
                  borderRadius: BorderRadius.circular(AppRadius.r6),
                  border: Border.all(
                      color: AppColors.primary.withAlpha(AppAlpha.a20),
                      width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(AppAlpha.a20),
                        borderRadius: BorderRadius.circular(AppRadius.r5),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: AppSpacing.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modo Estudio',
                            style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Pega un texto y genera material de estudio con IA',
                            style: tt.bodySmall?.copyWith(height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSpacing.s5),

              // ── Mode selector ────────────────────────────────────────────
              Text(
                'Tipo de material',
                style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: AppSpacing.s2),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _StudyMode.values.map((mode) {
                  final selected = _selectedMode == mode;
                  return CaptusPressable(
                    onTap: () => setState(() => _selectedMode = mode),
                    child: AnimatedContainer(
                      duration: AppDurations.fast,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.r5),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border,
                          width: selected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(mode.emoji,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: AppSpacing.s1),
                          Text(
                            mode.label,
                            style: tt.labelLarge?.copyWith(
                              color: selected
                                  ? AppColors.textOnPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: AppSpacing.s5),

              // ── Subject field ────────────────────────────────────────────
              Text(
                'Materia (opcional)',
                style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: AppSpacing.s2),
              TextField(
                controller: _subjectCtrl,
                style: tt.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'Ej. Biología, Cálculo diferencial…',
                ),
              ),

              SizedBox(height: AppSpacing.s4),

              // ── Content field ────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Contenido del documento',
                    style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _contentCtrl,
                    builder: (_, v, __) => Text(
                      '${v.text.length}/3000',
                      style: tt.bodySmall,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.s2),
              TextField(
                controller: _contentCtrl,
                maxLines: 8,
                maxLength: 3000,
                style: tt.labelLarge?.copyWith(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText:
                      'Pega aquí el texto del documento que quieres estudiar…',
                  counterStyle: tt.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.s5),

              // ── Generate / Nueva sesión buttons ──────────────────────────
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.r5),
                        ),
                      ),
                      onPressed: _isLoading ? null : _generate,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textOnPrimary,
                              ),
                            )
                          : const Icon(
                              Icons.auto_awesome_rounded,
                              color: AppColors.textOnPrimary,
                            ),
                      label: Text(
                        _isLoading ? 'Generando…' : 'Generar',
                        style: tt.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                  ),
                  if (_generated) ...[
                    const SizedBox(width: AppSpacing.s2 + 2),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.r5),
                        ),
                        side: const BorderSide(
                            color: AppColors.border, width: 0.5),
                      ),
                      onPressed: _reset,
                      child: Text(
                        'Nueva sesión',
                        style: tt.titleMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ],
              ),

              // ── Loading placeholder ──────────────────────────────────────
              if (_isLoading) ...[
                SizedBox(height: AppSpacing.s6),
                _LoadingPlaceholder(),
              ],

              // ── Result section ───────────────────────────────────────────
              if (_generated && _result != null) ...[
                SizedBox(height: AppSpacing.s6),
                Container(
                  padding: EdgeInsets.all(AppSpacing.s4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.r6),
                    border: Border.all(
                        color: AppColors.primary.withAlpha(AppAlpha.a20),
                        width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.s1),
                          Text(
                            '${_selectedMode.emoji} ${_selectedMode.label} generado',
                            style: tt.labelLarge?.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                      const Divider(
                          height: 20, color: AppColors.border),
                      MarkdownBody(
                        data: _result!,
                        selectable: true,
                        softLineBreak: true,
                        styleSheet: MarkdownStyleSheet(
                          p: tt.bodyMedium?.copyWith(height: 1.5),
                          strong: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                          h2: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                          h3: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          listBullet: tt.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: AppSpacing.s10),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingPlaceholder extends StatefulWidget {
  @override
  State<_LoadingPlaceholder> createState() => _LoadingPlaceholderState();
}

class _LoadingPlaceholderState extends State<_LoadingPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: AppDurations.deliberate,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final opacity = 0.4 + _ctrl.value * 0.6;
        return Container(
          padding: EdgeInsets.all(AppSpacing.s4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r6),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: AppSpacing.s2),
                  Text(
                    'Generando con IA…',
                    style: tt.labelLarge?.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.s3),
              ...[0.9, 0.7, 0.85, 0.6].map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s2),
                    child: Container(
                      height: 14,
                      width: MediaQuery.of(context).size.width * w,
                      decoration: BoxDecoration(
                        color: AppColors.surface2
                            .withAlpha((opacity * 255).round()),
                        borderRadius: BorderRadius.circular(AppRadius.r2),
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
