import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/ai_chat_provider.dart';

class AiTeacherToolsScreen extends ConsumerStatefulWidget {
  const AiTeacherToolsScreen({super.key});

  @override
  ConsumerState<AiTeacherToolsScreen> createState() =>
      _AiTeacherToolsScreenState();
}

class _AiTeacherToolsScreenState extends ConsumerState<AiTeacherToolsScreen> {
  // ── Semester Plan ──────────────────────────────────────────────────────────
  final _planCourseCtrl = TextEditingController();
  final _planTopicsCtrl = TextEditingController();
  final _planStartCtrl = TextEditingController();
  final _planWeeksCtrl = TextEditingController();
  final _planSessionsCtrl = TextEditingController();
  final _planFormKey = GlobalKey<FormState>();
  bool _planExpanded = false;

  // ── Rubric ─────────────────────────────────────────────────────────────────
  final _rubricActivityCtrl = TextEditingController();
  final _rubricSubjectCtrl = TextEditingController();
  final _rubricDescCtrl = TextEditingController();
  final _rubricScoreCtrl = TextEditingController();
  final _rubricFormKey = GlobalKey<FormState>();
  bool _rubricExpanded = false;

  // ── Question Bank ──────────────────────────────────────────────────────────
  final _bankTopicCtrl = TextEditingController();
  final _bankSubjectCtrl = TextEditingController();
  final _bankCountCtrl = TextEditingController();
  String _bankType = 'mixed';
  String _bankDifficulty = 'mixed';
  final _bankFormKey = GlobalKey<FormState>();
  bool _bankExpanded = false;

  bool _sending = false;

  @override
  void dispose() {
    _planCourseCtrl.dispose();
    _planTopicsCtrl.dispose();
    _planStartCtrl.dispose();
    _planWeeksCtrl.dispose();
    _planSessionsCtrl.dispose();
    _rubricActivityCtrl.dispose();
    _rubricSubjectCtrl.dispose();
    _rubricDescCtrl.dispose();
    _rubricScoreCtrl.dispose();
    _bankTopicCtrl.dispose();
    _bankSubjectCtrl.dispose();
    _bankCountCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendAndNavigate(String message) async {
    setState(() => _sending = true);
    try {
      await ref.read(aiChatProvider.notifier).send(message);
      if (mounted) context.go('/ai');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // ── Semester Plan submit ───────────────────────────────────────────────────

  Future<void> _submitPlan() async {
    if (!_planFormKey.currentState!.validate()) return;
    final msg =
        'Genera un plan de semestre para ${_planCourseCtrl.text.trim()} '
        'con los temas: ${_planTopicsCtrl.text.trim()}, '
        'comenzando el ${_planStartCtrl.text.trim()}, '
        '${_planWeeksCtrl.text.trim()} semanas, '
        '${_planSessionsCtrl.text.trim()} sesiones por semana';
    await _sendAndNavigate(msg);
  }

  // ── Rubric submit ──────────────────────────────────────────────────────────

  Future<void> _submitRubric() async {
    if (!_rubricFormKey.currentState!.validate()) return;
    final msg =
        'Genera una rúbrica para ${_rubricActivityCtrl.text.trim()} '
        'de ${_rubricSubjectCtrl.text.trim()}: ${_rubricDescCtrl.text.trim()}, '
        'puntaje máximo ${_rubricScoreCtrl.text.trim()}';
    await _sendAndNavigate(msg);
  }

  // ── Question Bank submit ───────────────────────────────────────────────────

  Future<void> _submitBank() async {
    if (!_bankFormKey.currentState!.validate()) return;
    final typeLabel = {
          'mixed': 'mixtas',
          'multiple_choice': 'de selección múltiple',
          'true_false': 'verdadero/falso',
          'open': 'abiertas',
        }[_bankType] ??
        _bankType;
    final diffLabel = {
          'mixed': 'mixta',
          'easy': 'fácil',
          'medium': 'media',
          'hard': 'difícil',
        }[_bankDifficulty] ??
        _bankDifficulty;
    final msg =
        'Genera ${_bankCountCtrl.text.trim()} preguntas tipo $typeLabel '
        'de dificultad $diffLabel sobre ${_bankTopicCtrl.text.trim()} '
        'de ${_bankSubjectCtrl.text.trim()}';
    await _sendAndNavigate(msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Herramientas IA Docente',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Intro ─────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: AppColors.primary.withAlpha(40)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Herramientas IA para Docentes',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Genera material académico con inteligencia artificial',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Tool 1: Semester Plan ─────────────────────────────────────
            _ToolCard(
              emoji: '📅',
              title: 'Plan de Semestre',
              subtitle: 'Crea un plan académico detallado por semanas',
              expanded: _planExpanded,
              onToggle: () =>
                  setState(() => _planExpanded = !_planExpanded),
              child: Form(
                key: _planFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Nombre del curso *'),
                    _ToolTextField(
                      controller: _planCourseCtrl,
                      hint: 'Ej. Cálculo Diferencial',
                      validator: _required,
                    ),
                    const SizedBox(height: 12),
                    _FieldLabel('Temas a cubrir *'),
                    _ToolTextField(
                      controller: _planTopicsCtrl,
                      hint: 'Ej. Límites, derivadas, integrales, aplicaciones',
                      maxLines: 3,
                      validator: _required,
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Fecha inicio *'),
                            _ToolTextField(
                              controller: _planStartCtrl,
                              hint: 'Ej. 2026-02-10',
                              validator: _required,
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2024),
                                  lastDate: DateTime(2030),
                                );
                                if (d != null) {
                                  _planStartCtrl.text =
                                      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Semanas *'),
                            _ToolTextField(
                              controller: _planWeeksCtrl,
                              hint: 'Ej. 16',
                              keyboardType: TextInputType.number,
                              validator: _requiredInt,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Sesiones/sem *'),
                            _ToolTextField(
                              controller: _planSessionsCtrl,
                              hint: 'Ej. 2',
                              keyboardType: TextInputType.number,
                              validator: _requiredInt,
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _GenerateButton(
                      sending: _sending,
                      onPressed: _submitPlan,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Tool 2: Rubric ────────────────────────────────────────────
            _ToolCard(
              emoji: '📋',
              title: 'Rúbrica de Evaluación',
              subtitle: 'Genera criterios de evaluación detallados',
              expanded: _rubricExpanded,
              onToggle: () =>
                  setState(() => _rubricExpanded = !_rubricExpanded),
              child: Form(
                key: _rubricFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel('Nombre de la actividad *'),
                    _ToolTextField(
                      controller: _rubricActivityCtrl,
                      hint: 'Ej. Proyecto final de programación',
                      validator: _required,
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Materia *'),
                            _ToolTextField(
                              controller: _rubricSubjectCtrl,
                              hint: 'Ej. Programación',
                              validator: _required,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Puntaje máximo *'),
                            _ToolTextField(
                              controller: _rubricScoreCtrl,
                              hint: 'Ej. 100',
                              keyboardType: TextInputType.number,
                              validator: _requiredInt,
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _FieldLabel('Descripción de la actividad'),
                    _ToolTextField(
                      controller: _rubricDescCtrl,
                      hint: 'Describe brevemente qué deben hacer los estudiantes…',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _GenerateButton(
                      sending: _sending,
                      onPressed: _submitRubric,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Tool 3: Question Bank ─────────────────────────────────────
            _ToolCard(
              emoji: '🎯',
              title: 'Banco de Preguntas',
              subtitle: 'Genera preguntas de evaluación con distintos niveles',
              expanded: _bankExpanded,
              onToggle: () =>
                  setState(() => _bankExpanded = !_bankExpanded),
              child: Form(
                key: _bankFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Tema *'),
                            _ToolTextField(
                              controller: _bankTopicCtrl,
                              hint: 'Ej. Derivadas',
                              validator: _required,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Materia *'),
                            _ToolTextField(
                              controller: _bankSubjectCtrl,
                              hint: 'Ej. Cálculo',
                              validator: _required,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Cantidad *'),
                            _ToolTextField(
                              controller: _bankCountCtrl,
                              hint: 'Ej. 10',
                              keyboardType: TextInputType.number,
                              validator: _requiredInt,
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Tipo de preguntas'),
                            _DropdownField<String>(
                              value: _bankType,
                              items: const [
                                DropdownMenuItem(
                                    value: 'mixed', child: Text('Mixtas')),
                                DropdownMenuItem(
                                    value: 'multiple_choice',
                                    child: Text('Selección múltiple')),
                                DropdownMenuItem(
                                    value: 'true_false',
                                    child: Text('V / F')),
                                DropdownMenuItem(
                                    value: 'open', child: Text('Abiertas')),
                              ],
                              onChanged: (v) =>
                                  setState(() => _bankType = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Dificultad'),
                            _DropdownField<String>(
                              value: _bankDifficulty,
                              items: const [
                                DropdownMenuItem(
                                    value: 'mixed', child: Text('Mixta')),
                                DropdownMenuItem(
                                    value: 'easy', child: Text('Fácil')),
                                DropdownMenuItem(
                                    value: 'medium', child: Text('Media')),
                                DropdownMenuItem(
                                    value: 'hard', child: Text('Difícil')),
                              ],
                              onChanged: (v) =>
                                  setState(() => _bankDifficulty = v!),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _GenerateButton(
                      sending: _sending,
                      onPressed: _submitBank,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo requerido' : null;

  String? _requiredInt(String? v) {
    if (v == null || v.trim().isEmpty) return 'Requerido';
    if (int.tryParse(v.trim()) == null) return 'Número inválido';
    return null;
  }
}

// ── Reusable widgets ───────────────────────────────────────────────────────────

class _ToolCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  const _ToolCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: expanded ? AppColors.primary : AppColors.border,
          width: expanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: expanded
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ToolTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;

  const _ToolTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: onTap != null,
      onTap: onTap,
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _GenerateButton extends StatelessWidget {
  final bool sending;
  final VoidCallback onPressed;

  const _GenerateButton({
    required this.sending,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: sending ? null : onPressed,
        icon: sending
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.textOnPrimary),
              )
            : const Icon(Icons.auto_awesome_rounded, color: AppColors.textOnPrimary),
        label: Text(
          sending ? 'Generando…' : 'Generar con IA',
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textOnPrimary),
        ),
      ),
    );
  }
}
