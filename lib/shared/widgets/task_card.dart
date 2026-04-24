import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task.dart';
import 'countdown_chip.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;
  final bool showSubtaskProgress;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onComplete,
    this.onDelete,
    this.showSubtaskProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;

    return Slidable(
      key: ValueKey(task.id),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => onComplete?.call(),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: Icons.check_rounded,
            label: 'Listo',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              bottomLeft: Radius.circular(14),
            ),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete?.call(),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline_rounded,
            label: 'Eliminar',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.surface2 : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: task.isOverdue
                  ? AppColors.error.withAlpha(60)
                  : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Fila superior: checkbox + título + badge prioridad ───────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CircleCheckbox(
                      isCompleted: isCompleted,
                      onTap: onComplete,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        task.title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? AppColors.textDisabled
                              : AppColors.textPrimary,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: AppColors.textDisabled,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _PriorityBadge(priority: task.priority),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Fila inferior: curso · fecha ─────────────────────────────
                Row(
                  children: [
                    const SizedBox(width: 32), // alinea con el título
                    if (task.courseName != null) ...[
                      Text(
                        task.courseName!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (task.dueDate != null)
                        Text(
                          ' · ',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textDisabled,
                          ),
                        ),
                    ],
                    if (task.dueDate != null)
                      CountdownChip(dueDate: task.dueDate!, compact: true),
                    const Spacer(),
                    if (task.subtasks.isNotEmpty && showSubtaskProgress)
                      Text(
                        '${task.completedSubtasks} de ${task.subtasks.length} subtareas',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),

                // ── Barra de progreso ────────────────────────────────────────
                if (task.subtasks.isNotEmpty && showSubtaskProgress) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(width: 32),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: task.completedSubtasks /
                                task.subtasks.length,
                            minHeight: 5,
                            backgroundColor: AppColors.surface2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isCompleted
                                  ? AppColors.textDisabled
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(task.completedSubtasks / task.subtasks.length * 100).round()}%',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Badge de prioridad ────────────────────────────────────────────────────────

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    switch (priority) {
      case TaskPriority.high:
        return _badge('Alta', AppColors.error, AppColors.errorLight);
      case TaskPriority.medium:
        return _badge('Media', AppColors.warning, AppColors.warningLight);
      case TaskPriority.low:
        return _badge('Baja', AppColors.primary, AppColors.primaryLight);
    }
  }

  Widget _badge(String label, Color text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }
}

// ── Checkbox circular ─────────────────────────────────────────────────────────

class _CircleCheckbox extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback? onTap;

  const _CircleCheckbox({required this.isCompleted, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isCompleted ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: isCompleted
            ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
            : null,
      ),
    );
  }
}