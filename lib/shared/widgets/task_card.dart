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
  final VoidCallback? onEdit;
  final bool showSubtaskProgress;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onComplete,
    this.onDelete,
    this.onEdit,
    this.showSubtaskProgress = true,
  });

  bool get _isCompleted => task.status == TaskStatus.completed || task.completed;
  bool get _isOverdue => task.isOverdue;
  bool get _isDisabled => _isCompleted || _isOverdue;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(task.id),
      startActionPane: _isDisabled
          ? null
          : ActionPane(
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
      endActionPane: _isDisabled
          ? null
          : ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (_) => onEdit?.call(),
                  backgroundColor: AppColors.info,
                  foregroundColor: Colors.white,
                  icon: Icons.edit_rounded,
                  label: 'Editar',
                ),
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
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isOverdue ? 0.7 : 1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: _isCompleted
                  ? AppColors.surface2
                  : _isOverdue
                      ? AppColors.errorLight.withAlpha(38)
                      : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isOverdue
                    ? AppColors.error.withAlpha(76)
                    : _isCompleted
                        ? AppColors.border
                        : AppColors.border,
                width: 1.5,
              ),
              boxShadow: _isOverdue
                  ? [
                      BoxShadow(
                        color: AppColors.error.withAlpha(25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CircleCheckbox(
                        isCompleted: _isCompleted,
                        isDisabled: _isDisabled,
                        onTap: _isDisabled ? null : onComplete,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _isCompleted
                                    ? AppColors.textDisabled
                                    : _isOverdue
                                        ? AppColors.error
                                        : AppColors.textPrimary,
                                decoration: _isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: AppColors.textDisabled,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (task.description != null &&
                                task.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                task.description!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: _isCompleted
                                      ? AppColors.textDisabled
                                      : AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _PriorityBadge(priority: task.priority),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const SizedBox(width: 32),
                      if (task.categoryName != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface2,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.label_outline,
                                size: 12,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.categoryName!,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
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
                  if (task.subtasks.isNotEmpty && showSubtaskProgress) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const SizedBox(width: 32),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: task.completedSubtasks / task.subtasks.length,
                              minHeight: 5,
                              backgroundColor: AppColors.surface2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _isCompleted
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
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    String label;
    Color textColor;
    Color bgColor;

    switch (priority) {
      case TaskPriority.high:
        label = 'Alta';
        textColor = AppColors.error;
        bgColor = AppColors.errorLight;
        break;
      case TaskPriority.medium:
        label = 'Media';
        textColor = AppColors.warning;
        bgColor = AppColors.warningLight;
        break;
      case TaskPriority.low:
        label = 'Baja';
        textColor = AppColors.primary;
        bgColor = AppColors.primaryLight;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _CircleCheckbox extends StatelessWidget {
  final bool isCompleted;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _CircleCheckbox({
    required this.isCompleted,
    required this.isDisabled,
    this.onTap,
  });

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
            color: isCompleted
                ? AppColors.primary
                : isDisabled
                    ? AppColors.textDisabled
                    : AppColors.border,
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