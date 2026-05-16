import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/tasks_provider.dart';
import '../../../models/task.dart';

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
    final tasksAsync = ref.watch(tasksNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Agenda',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
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
              const SizedBox(height: 12),
              Text('No se pudo cargar la agenda',
                  style: GoogleFonts.inter(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => ref.invalidate(tasksNotifierProvider),
                child: Text('Reintentar',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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
                  const SizedBox(height: 16),
                  Text(
                    'Sin tareas próximas',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Todas tus tareas están al día.',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ref.refresh(tasksNotifierProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16),
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
                      margin: const EdgeInsets.only(bottom: 8, top: 16),
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppColors.primary.withAlpha(AppAlpha.a15)
                            : AppColors.surface2,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isToday
                            ? "Hoy — ${DateFormat("d 'de' MMMM", 'es').format(entry.key)}"
                            : DateFormat("EEEE d 'de' MMMM", 'es')
                                .format(entry.key),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isToday
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    ...entry.value.map((task) => GestureDetector(
                          onTap: () {
                            if (task.id != null) {
                              context.push('/tasks/${task.id}');
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
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
                                          style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary)),
                                      if (task.courseName != null)
                                        Text(task.courseName!,
                                            style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color:
                                                    AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                if (task.dueDate != null)
                                  Text(
                                    DateFormat('h:mm a').format(task.dueDate!),
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
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
