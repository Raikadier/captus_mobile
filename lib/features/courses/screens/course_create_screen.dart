import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/courses_provider.dart';

class CourseCreateScreen extends ConsumerStatefulWidget {
  const CourseCreateScreen({super.key});

  @override
  ConsumerState<CourseCreateScreen> createState() => _CourseCreateScreenState();
}

class _CourseCreateScreenState extends ConsumerState<CourseCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(teacherCoursesNotifierProvider.notifier).createCourse(
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
          );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Nuevo curso',
          style: tt.headlineLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.s6),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Información del curso',
                style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s6),
              TextFormField(
                controller: _titleCtrl,
                style: tt.bodyMedium?.copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Nombre del curso',
                  hintText: 'Ej. Estructuras de Datos',
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'El nombre es requerido'
                    : null,
              ),
              const SizedBox(height: AppSpacing.s5),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                style: tt.bodyMedium?.copyWith(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Descripción del curso...',
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r5),
                    ),
                  ),
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Crear curso',
                          style: tt.headlineSmall,
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.s6),
            ],
          ),
        ),
      ),
    );
  }
}
