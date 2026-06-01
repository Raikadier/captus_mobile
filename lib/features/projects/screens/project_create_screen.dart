import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/services/api_client.dart';

class ProjectCreateScreen extends StatefulWidget {
  const ProjectCreateScreen({super.key});

  @override
  State<ProjectCreateScreen> createState() => _ProjectCreateScreenState();
}

class _ProjectCreateScreenState extends State<ProjectCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ApiClient.instance.post('/projects', data: {
        'title': _titleCtrl.text.trim(),
        if (_descCtrl.text.trim().isNotEmpty)
          'description': _descCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proyecto creado'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear el proyecto: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      restorationId: 'project_create_screen',
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Nuevo proyecto',
          style: tt.headlineMedium,
        ),
        actions: [
          _saving
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: AppSpacing.s4),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _save,
                  child: Text(
                    'Crear',
                    style: tt.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
          const SizedBox(width: AppSpacing.s2),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.s4),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r6),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del proyecto',
                    style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    'Título *',
                    style: tt.titleMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Nombre del proyecto',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'El título es requerido'
                            : null,
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    'Descripción (opcional)',
                    style: tt.titleMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: '¿De qué trata el proyecto?',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s6),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r5),
                  ),
                ),
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textOnPrimary,
                        ),
                      )
                    : Text(
                        'Crear proyecto',
                        style: tt.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
