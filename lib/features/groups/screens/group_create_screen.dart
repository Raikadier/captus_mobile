import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../core/providers/courses_provider.dart';
import '../../../core/services/api_client.dart';
import '../../../models/course.dart';

class GroupCreateScreen extends ConsumerStatefulWidget {
  const GroupCreateScreen({super.key});

  @override
  ConsumerState<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends ConsumerState<GroupCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  bool _isPrivate = false;
  bool _loading = false;
  String? _selectedCourseId;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null) {
      setState(() => _error = 'Selecciona un curso para el grupo');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ref.read(createGroupNotifierProvider.notifier).createGroup(
            name: _nameCtrl.text.trim(),
            courseId: _selectedCourseId!,
            description: _descriptionCtrl.text.trim(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Grupo "${_nameCtrl.text.trim()}" creado.',
          ),
          backgroundColor: AppColors.surface2,
        ),
      );
      context.pop();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Error inesperado');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      restorationId: 'group_create_screen',
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          tooltip: 'Volver',
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Nuevo grupo',
          style: tt.headlineMedium,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s3),
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  )
                : FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s4, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.r4)),
                    ),
                    child: Text(
                      'Crear',
                      style: tt.titleMedium,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.s4),
          children: [
            // ── Avatar placeholder ─────────────────────────────────────
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(AppAlpha.a15),
                      borderRadius: BorderRadius.circular(AppRadius.r8),
                    ),
                    child: const Icon(Icons.group_rounded,
                        color: AppColors.primary, size: 40),
                  ),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.r3),
                      border: Border.all(
                          color: AppColors.background, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: AppColors.textOnPrimary, size: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s6),

            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.s3),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(AppAlpha.a10),
                  borderRadius: BorderRadius.circular(AppRadius.r4),
                  border: Border.all(
                      color: AppColors.error.withAlpha(AppAlpha.a30)),
                ),
                child: Text(
                  _error!,
                  style: tt.bodySmall?.copyWith(color: AppColors.error),
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
            ],

            // ── Curso ──────────────────────────────────────────────────
            _SectionLabel('CURSO'),
            coursesAsync.when(
              loading: () => Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.r5),
                  border: Border.all(
                      color: AppColors.border, width: 0.5),
                ),
                child: const Center(child: LinearProgressIndicator()),
              ),
              error: (_, __) => Text(
                'No se pudieron cargar los cursos',
                style: tt.bodySmall?.copyWith(color: AppColors.error),
              ),
              data: (courses) => _CoursePicker(
                courses: courses,
                selectedId: _selectedCourseId,
                onChanged: (id) =>
                    setState(() => _selectedCourseId = id),
              ),
            ),
            const SizedBox(height: AppSpacing.s5),

            // ── Nombre ────────────────────────────────────────────────
            _SectionLabel('INFORMACIÓN DEL GRUPO'),
            _buildField(
              controller: _nameCtrl,
              label: 'Nombre del grupo',
              hint: 'Ej. Proyecto Final — Ing. Software',
              icon: Icons.group_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                if (v.trim().length < 3) {
                  return 'Mínimo 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.s3),

            // ── Descripción ───────────────────────────────────────────
            _buildField(
              controller: _descriptionCtrl,
              label: 'Descripción (opcional)',
              hint: 'De qué trata este grupo…',
              icon: Icons.notes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.s5),

            // ── Privacidad ────────────────────────────────────────────
            _SectionLabel('PRIVACIDAD'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r5),
                border:
                    Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (_isPrivate
                              ? AppColors.warning
                              : AppColors.success)
                          .withAlpha(AppAlpha.a15),
                      borderRadius: BorderRadius.circular(AppRadius.r4),
                    ),
                    child: Icon(
                      _isPrivate
                          ? Icons.lock_rounded
                          : Icons.lock_open_rounded,
                      color: _isPrivate
                          ? AppColors.warning
                          : AppColors.success,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isPrivate ? 'Privado' : 'Público',
                          style: tt.titleMedium,
                        ),
                        Text(
                          _isPrivate
                              ? 'Solo por invitación'
                              : 'Cualquiera puede unirse con código',
                          style: tt.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isPrivate,
                    onChanged: (v) => setState(() => _isPrivate = v),
                    activeColor: AppColors.warning,
                    inactiveTrackColor:
                        AppColors.success.withAlpha(AppAlpha.a30),
                    inactiveThumbColor: AppColors.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }
}

class _CoursePicker extends StatelessWidget {
  final List<CourseModel> courses;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const _CoursePicker({
    required this.courses,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    if (courses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r5),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Text(
          'No tienes cursos disponibles',
          style: tt.bodySmall,
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: selectedId,
      onChanged: onChanged,
      dropdownColor: AppColors.surface,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.school_rounded,
            color: AppColors.textSecondary, size: 20),
        hintText: 'Selecciona un curso',
      ),
      items: courses
          .map((c) => DropdownMenuItem<String>(
                value: c.id,
                child: Text(
                  c.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: AppSpacing.s1),
      child: Text(
        label,
        style: tt.labelMedium?.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
