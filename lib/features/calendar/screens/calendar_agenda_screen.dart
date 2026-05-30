import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/tasks_provider.dart';
import '../../../models/task.dart';
import '../../../shared/widgets/captus_pressable.dart';

class CalendarAgendaScreen extends ConsumerWidget {
  const CalendarAgendaScreen({super.key});

  Map<DateTime, List<TaskModel>> _groupByDate(List<TaskModel> tasks) {
    final map = <DateTime, List<TaskModel>>{};
    for (final t in tasks) {
      if (t.dueDate == null) continue;
      final day = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      map[day] ??= [];
      map[day]!.add(t);
    }
    final sorted = Map.fromEntries(
        map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
    return sorted;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final tasksAsync = ref.watch(tasksNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Agenda',
          style: tt.headlineMedium,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: tasksAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              SizedBox(height: AppSpacing.s3),
              Text('No se pudo cargar la agenda',
                  style: tt.bodySmall),
              SizedBox(height: AppSpacing.s2),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(tasksNotifierProvider),
                child: Text('Reintentar',
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        data: (allTasks) {
          // Solo tareas pendientes con fecha
          final pending = allTasks
              .where((t) => !t.completed && t.dueDate != null)
              .toList();
          final grouped = _groupByDate(pending);

          if (grouped.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.event_available_rounded,
                      size: 64, color: AppColors.textSecondary),
                  SizedBox(height: AppSpacing.s4),
                  Text(
                    'Sin tareas próximas',
                    style: tt.headlineSmall,
                  ),
                  SizedBox(height: AppSpacing.s2),
                  Text(
                    'Todas tus tareas están al día.',
                    style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ref.refresh(tasksNotifierProvider.future),
            child: ListView(
              padding: EdgeInsets.all(AppSpacing.s4),
              children: grouped.entries.map((entry) {
                final isToday = entry.key.day == DateTime.now().day &&
                    entry.key.month == DateTime.now().month &&
                    entry.key.year == DateTime.now().year;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      margin: const EdgeInsets.only(bottom: AppSpacing.s2, top: AppSpacing.s4),
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppColors.primary.withAlpha(AppAlpha.a15)
                            : AppColors.surface2,
                        borderRadius: BorderRadius.circular(AppRadius.r2),
                      ),
                      child: Text(
                        isToday
                            ? "Hoy — ${DateFormat("d 'de' MMMM", 'es').format(entry.key)}"
                            : DateFormat("EEEE d 'de' MMMM", 'es')
                                .format(entry.key),
                        style: tt.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isToday
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    ...entry.value.map((task) => CaptusPressable(
                          onTap: () {
                            if (task.id != null) {
                              context.push('/tasks/${task.id}');
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.s2),
                            padding: EdgeInsets.all(AppSpacing.s3),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.border, width: 0.5),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color:
                                        task.priority == TaskPriority.high
                                            ? AppColors.priorityHigh
                                            : task.priority ==
                                                    TaskPriority.medium
                                                ? AppColors.priorityMedium
                                                : AppColors.priorityLow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(task.title,
                                          style: tt.labelLarge?.copyWith(
                                              fontWeight: FontWeight.w600)),
                                      if (task.courseName != null)
                                        Text(task.courseName!,
                                            style: tt.labelMedium?.copyWith(
                                                color:
                                                    AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                if (task.dueDate != null)
                                  Text(
                                    DateFormat('h:mm a').format(task.dueDate!),
                                    style: tt.labelMedium?.copyWith(
                                        color: AppColors.textSecondary),
                                  ),
                              ],
                            ),
                          ),
                        )),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
