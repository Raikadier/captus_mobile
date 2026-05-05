import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task.dart';
import 'countdown_chip.dart';
import 'priority_bar.dart';

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
            foregroundColor: Colors.black,
            icon: Icons.check_rounded,
            label: 'Listo',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
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
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: task.isOverdue
                  ? AppColors.error.withAlpha(76)
                  : AppColors.border,
              width: 0.5,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                PriorityBar(priority: task.priority),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
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
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _CheckboxWidget(
                              isCompleted: isCompleted,
                              onTap: onComplete,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (task.courseName != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surface2,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  task.courseName!,
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            if (task.dueDate != null)
                              CountdownChip(
                                  dueDate: task.dueDate!, compact: true),
                            const Spacer(),
                            if (task.subtasks.isNotEmpty && showSubtaskProgress)
                              Text(
                                '${task.completedSubtasks}/${task.subtasks.length}',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                        if (task.subtasks.isNotEmpty &&
                            showSubtaskProgress) ...[
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: task.subtasks.isEmpty
                                ? 0
                                : task.completedSubtasks / task.subtasks.length,
                            minHeight: 3,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckboxWidget extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback? onTap;

  const _CheckboxWidget({required this.isCompleted, this.onTap});

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
            width: 2,
          ),
        ),
        child: isCompleted
            ? const Icon(Icons.check_rounded, size: 14, color: Colors.black)
            : null,
      ),
    );
  }
}
