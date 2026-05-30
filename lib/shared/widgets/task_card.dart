import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_animations.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_radius.dart';
import '../../models/task.dart';
import 'captus_pressable.dart';
import 'countdown_chip.dart';

/// Premium task card — Captus Design System v2.
///
/// Upgrades vs v1:
///   - AppShadows.sm elevation on default state (depth without heaviness)
///   - CaptusPressable wrapper for scale + opacity press feedback
///   - AppSpacing tokens for all padding/margin values
///   - Refined typography via theme text styles
///   - AnimatedContainer for smooth state transitions
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
    final tt = Theme.of(context).textTheme;

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
                  foregroundColor: AppColors.textOnPrimary,
                  icon: Icons.check_rounded,
                  label: 'Listo',
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.r6),
                    bottomLeft: Radius.circular(AppRadius.r6),
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
                  foregroundColor: AppColors.textOnPrimary,
                  icon: Icons.edit_rounded,
                  label: 'Editar',
                ),
                SlidableAction(
                  onPressed: (_) => onDelete?.call(),
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.textOnPrimary,
                  icon: Icons.delete_outline_rounded,
                  label: 'Eliminar',
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(AppRadius.r6),
                    bottomRight: Radius.circular(AppRadius.r6),
                  ),
                ),
              ],
            ),
      child: CaptusPressable(
        onTap: onTap,
        child: AnimatedOpacity(
          duration: AppDurations.standard,
          opacity: _isOverdue ? 0.75 : 1.0,
          child: AnimatedContainer(
            duration: AppDurations.standard,
            curve: AppCurves.standard,
            margin: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageMargin,
              vertical: AppSpacing.s1 + 2, // 6px — tighter than before
            ),
            decoration: BoxDecoration(
              color: _isCompleted
                  ? AppColors.surface2
                  : _isOverdue
                      ? AppColors.errorLight
                      : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r6),
              border: Border.all(
                color: _isOverdue
                    ? AppColors.error.withAlpha(AppAlpha.a30)
                    : AppColors.border,
                width: 1,
              ),
              // v2: subtle shadow on default state for depth
              boxShadow: _isCompleted
                  ? null
                  : _isOverdue
                      ? [
                          BoxShadow(
                            color: AppColors.error.withAlpha(AppAlpha.a12),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : AppShadows.sm,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top row: checkbox + title + priority badge ──────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CircleCheckbox(
                        isCompleted: _isCompleted,
                        isDisabled: _isDisabled,
                        onTap: _isDisabled ? null : onComplete,
                      ),
                      const SizedBox(width: AppSpacing.s2 + 2), // 10px
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: (tt.titleMedium ?? const TextStyle()).copyWith(
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
                              const SizedBox(height: AppSpacing.s1),
                              Text(
                                task.description!,
                                style: (tt.bodySmall ?? const TextStyle()).copyWith(
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
                      const SizedBox(width: AppSpacing.s2),
                      _PriorityBadge(priority: task.priority),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.s2 + 2), // 10px

                  // ── Bottom row: category + due date + subtask count ─────
                  Row(
                    children: [
                      const SizedBox(width: AppSpacing.s8), // indent to align with title
                      if (task.categoryName != null) ...[
                        _CategoryChip(label: task.categoryName!),
                        if (task.dueDate != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s1),
                            child: Text(
                              '·',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textDisabled,
                              ),
                            ),
                          ),
                      ],
                      if (task.dueDate != null)
                        CountdownChip(dueDate: task.dueDate!, compact: true),
                      const Spacer(),
                      if (task.subtasks.isNotEmpty && showSubtaskProgress)
                        Text(
                          '${task.completedSubtasks}/${task.subtasks.length}',
                          style: (tt.labelSmall ?? const TextStyle()).copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),

                  // ── Subtask progress bar ────────────────────────────────
                  if (task.subtasks.isNotEmpty && showSubtaskProgress) ...[
                    const SizedBox(height: AppSpacing.s2),
                    Row(
                      children: [
                        const SizedBox(width: AppSpacing.s8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: LinearProgressIndicator(
                              value: task.completedSubtasks /
                                  task.subtasks.length,
                              minHeight: 4,
                              backgroundColor: AppColors.surface3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _isCompleted
                                    ? AppColors.textDisabled
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s2),
                        Text(
                          '${(task.completedSubtasks / task.subtasks.length * 100).round()}%',
                          style: (tt.labelSmall ?? const TextStyle()).copyWith(
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

// ── Category chip ──────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s2 - 2, // 6px
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.r1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.label_outline_rounded,
            size: 11,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.s1),
          Text(
            label,
            style: tt.labelMedium!.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Priority badge ─────────────────────────────────────────────────────────────

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final (String label, Color text, Color bg) = switch (priority) {
      TaskPriority.high   => ('Alta',  AppColors.error,   AppColors.errorLight),
      TaskPriority.medium => ('Media', AppColors.warning, AppColors.warningLight),
      TaskPriority.low    => ('Baja',  AppColors.primary, AppColors.primaryLight),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.r2),
      ),
      child: Text(
        label,
        style: tt.labelMedium,
      ),
    );
  }
}

// ── Circle checkbox ────────────────────────────────────────────────────────────

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
        duration: AppDurations.standard,
        curve: AppCurves.springShort,
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
            ? const Icon(
                Icons.check_rounded,
                size: 13,
                color: AppColors.textOnPrimary,
              )
            : null,
      ),
    );
  }
}
