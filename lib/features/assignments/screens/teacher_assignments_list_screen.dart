import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/providers/assignments_provider.dart';
import '../../../shared/widgets/captus_fab.dart';

class TeacherAssignmentsListScreen extends ConsumerWidget {
  const TeacherAssignmentsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final assignmentsAsync = ref.watch(teacherAssignmentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Mis Asignaciones',
          style: tt.headlineSmall,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(teacherAssignmentsProvider.notifier).refresh(),
        child: assignmentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                SizedBox(height: AppSpacing.s4),
                Text('No se pudieron cargar las tareas',
                    style: tt.bodyMedium!.copyWith(color: AppColors.textSecondary)),
                SizedBox(height: AppSpacing.s4),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(teacherAssignmentsProvider.notifier).refresh(),
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
                    const Icon(Icons.assignment_outlined,
                        size: 64, color: AppColors.textDisabled),
                    SizedBox(height: AppSpacing.s4),
                    Text(
                      'Aún no has creado tareas',
                      style: tt.headlineMedium,
                    ),
                    SizedBox(height: AppSpacing.s2),
                    Text(
                      'Crea tu primera asignación para tus alumnos',
                      style: tt.bodyMedium!.copyWith(color: AppColors.textSecondary),
                    ),
                    SizedBox(height: AppSpacing.s6),
                    ElevatedButton.icon(
                      onPressed: () =>
                          context.push('/teacher/assignments/create'),
                      icon: const Icon(Icons.add),
                      label: const Text('Crear tarea'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
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
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(assignment.title,
                        style: tt.titleMedium!.copyWith(color: AppColors.textPrimary)),
                    subtitle: Text(assignment.description ?? 'Sin descripción',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall!.copyWith(color: AppColors.textSecondary)),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: AppColors.textSecondary),
                    onTap: () {
                      context
                          .push('/teacher/assignments/${assignment.id}/review');
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: CaptusFab(
        onPressed: () => context.push('/teacher/assignments/create'),
        icon: Icons.add_rounded,
        tooltip: 'Crear asignación',
      ),
    );
  }
}
