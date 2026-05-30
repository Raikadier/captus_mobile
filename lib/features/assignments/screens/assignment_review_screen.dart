import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/assignments_provider.dart';

class AssignmentReviewScreen extends ConsumerStatefulWidget {
  final String assignmentId;
  const AssignmentReviewScreen({super.key, required this.assignmentId});

  @override
  ConsumerState<AssignmentReviewScreen> createState() =>
      _AssignmentReviewScreenState();
}

class _AssignmentReviewScreenState
    extends ConsumerState<AssignmentReviewScreen> {
  void _showGradeDialog(BuildContext context, String submissionId) {
    double grade = 0.0;
    String feedback = '';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Calificar Entrega',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Nota'),
                onChanged: (val) => grade = double.tryParse(val) ?? 0.0,
              ),
              SizedBox(height: AppSpacing.s3),
              TextField(
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Feedback'),
                onChanged: (val) => feedback = val,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                ref.read(teacherAssignmentsProvider.notifier).gradeSubmission(
                    widget.assignmentId, submissionId, grade, feedback);
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final submissionsAsync =
        ref.watch(submissionsProvider(widget.assignmentId));

    return Scaffold(
      restorationId: 'assignment_review_screen',
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Revisar Entregas',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: submissionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              SizedBox(height: AppSpacing.s3),
              Text('No se pudo cargar la entrega',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary)),
              SizedBox(height: AppSpacing.s2),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(submissionsProvider(widget.assignmentId)),
                child: Text('Reintentar', style: Theme.of(context).textTheme.titleMedium),
              ),
            ],
          ),
        ),
        data: (submissions) {
          if (submissions.isEmpty) {
            return const Center(
                child: Text('Aún no hay entregas para esta asignación.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.s4),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final sub = submissions[index];
              return Card(
                color: AppColors.surface,
                margin: const EdgeInsets.only(bottom: AppSpacing.s3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r5)),
                child: ListTile(
                  title: Text('Estudiante: ${sub.studentId.substring(0, 8)}...',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AppColors.textPrimary)),
                  subtitle: Text(
                      'Estado: ${sub.status}\nNota: ${sub.grade ?? "Sin nota"}',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.textSecondary)),
                  trailing: const Icon(Icons.grading, color: AppColors.primary),
                  onTap: () => _showGradeDialog(context, sub.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
