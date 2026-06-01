import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/assignments_provider.dart';

class StudentAssignmentsScreen extends ConsumerWidget {
  const StudentAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final assignmentsAsync = ref.watch(studentAssignmentsProvider);

    return Scaffold(
      restorationId: 'student_assignments_screen',
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Mis Tareas',
          style: tt.headlineSmall,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(studentAssignmentsProvider.notifier).refresh(),
        child: assignmentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded,
                    size: 48, color: AppColors.textDisabled),
                SizedBox(height: AppSpacing.s3),
                Text('No se pudieron cargar las tareas',
                    style: tt.bodyMedium!.copyWith(color: AppColors.textSecondary)),
                SizedBox(height: AppSpacing.s4),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(studentAssignmentsProvider.notifier).refresh(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
          data: (assignments) {
            if (assignments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.assignment_turned_in_outlined,
                        size: 64, color: AppColors.textDisabled),
                    SizedBox(height: AppSpacing.s4),
                    Text(
                      'No tienes tareas pendientes',
                      style: tt.headlineMedium,
                    ),
                    SizedBox(height: AppSpacing.s2),
                    Text(
                      '¡Buen trabajo! Estás al día con tus deberes.',
                      style: tt.bodyMedium!.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.s4),
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                return Card(
                  color: AppColors.surface,
                  margin: const EdgeInsets.only(bottom: AppSpacing.s3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r5)),
                  child: ListTile(
                    title: Text(assignment.title,
                        style: tt.titleMedium!.copyWith(color: AppColors.textPrimary)),
                    subtitle: Text(
                        'Vence: ${assignment.dueDate.day}/${assignment.dueDate.month}/${assignment.dueDate.year}',
                        style: tt.bodySmall!.copyWith(color: AppColors.textSecondary)),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: AppColors.textSecondary),
                    onTap: () {
                      context
                          .push('/student/assignments/${assignment.id}/submit');
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
