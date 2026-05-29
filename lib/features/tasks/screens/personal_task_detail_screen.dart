import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/providers/tasks_provider.dart';
import '../../../core/utils/app_errors.dart';
import '../../../models/task.dart';

class PersonalTaskDetailScreen extends ConsumerStatefulWidget {
  final int taskId;

  const PersonalTaskDetailScreen({
    super.key,
    required this.taskId,
  });

  @override
  ConsumerState<PersonalTaskDetailScreen> createState() => _PersonalTaskDetailScreenState();
}

class _PersonalTaskDetailScreenState extends ConsumerState<PersonalTaskDetailScreen> {
  bool _isLoading = true;
  TaskModel? _task;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    setState(() => _isLoading = true);
    final task = await ref.read(tasksServiceProvider).fetchById(widget.taskId);
    if (mounted) {
      setState(() {
        _task = task;
        _isLoading = false;
      });
    }
  }

  bool get _isCompleted => _task?.completed ?? false;
  bool get _isOverdue => _task?.isOverdue ?? false;
  bool get _isDisabled => _isCompleted || _isOverdue;

  Future<void> _completeTask() async {
    if (_task == null || _isDisabled) return;

    try {
      await ref.read(tasksNotifierProvider.notifier).completeWithSubtasks(widget.taskId);
      await _loadTask();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.textOnPrimary),
                const SizedBox(width: AppSpacing.s2),
                const Text('Tarea completada'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e, fallback: 'No se pudo completar la tarea. Intenta de nuevo.')), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Estás seguro de eliminar "${_task?.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && _task != null) {
      try {
        await ref.read(tasksNotifierProvider.notifier).delete(widget.taskId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.delete, color: AppColors.textOnPrimary),
                  const SizedBox(width: AppSpacing.s2),
                  const Text('Tarea eliminada'),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(friendlyError(e, fallback: 'No se pudo eliminar la tarea. Intenta de nuevo.')), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  Future<void> _toggleSubtask(String subtaskId, bool completed) async {
    try {
      await ref.read(tasksNotifierProvider.notifier).completeSubtask(
        widget.taskId,
        int.parse(subtaskId),
        completed,
      );
      await _loadTask();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e, fallback: 'No se pudo actualizar la subtarea. Intenta de nuevo.')), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Tarea')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_task == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Tarea')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: AppSpacing.s4),
              Text(
                'Tarea no encontrada',
                style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.s4),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    final progress = _task!.subtasks.isNotEmpty
        ? _task!.completedSubtasks / _task!.subtasks.length
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isCompleted ? 'Tarea completada' : 'Tarea'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (!_isDisabled) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/tasks/personal/${widget.taskId}/edit'),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteTask,
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedOpacity(
              opacity: _isOverdue ? 0.7 : 1.0,
              duration: AppDurations.fast,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.s4),
                decoration: BoxDecoration(
                  color: _isCompleted
                      ? AppColors.surface2
                      : _isOverdue
                          ? AppColors.errorLight.withAlpha(38)
                          : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isOverdue
                        ? AppColors.error.withAlpha(76)
                        : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _isDisabled ? null : _completeTask,
                          child: AnimatedContainer(
                            duration: AppDurations.fast,
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isCompleted ? AppColors.primary : AppColors.surface,
                              border: Border.all(
                                color: _isCompleted
                                    ? AppColors.primary
                                    : _isDisabled
                                        ? AppColors.textDisabled
                                        : AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: _isCompleted
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 18,
                                    color: AppColors.textOnPrimary,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s3),
                        Expanded(
                          child: Text(
                            _task!.title,
                            style: tt.headlineLarge?.copyWith(
                              color: _isCompleted
                                  ? AppColors.textDisabled
                                  : _isOverdue
                                      ? AppColors.error
                                      : AppColors.textPrimary,
                              decoration: _isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Row(
                      children: [
                        _buildInfoChip(
                          icon: Icons.flag_rounded,
                          label: _task!.priority.label,
                          color: _task!.priority == TaskPriority.high
                              ? AppColors.error
                              : _task!.priority == TaskPriority.medium
                                  ? AppColors.warning
                                  : AppColors.primary,
                        ),
                        if (_task!.categoryName != null) ...[
                          const SizedBox(width: AppSpacing.s2),
                          _buildInfoChip(
                            icon: Icons.label_outline,
                            label: _task!.categoryName!,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ],
                    ),
                    if (_task!.dueDate != null) ...[
                      const SizedBox(height: AppSpacing.s3),
                      _buildInfoChip(
                        icon: Icons.calendar_today_outlined,
                        label: DateFormat("d 'de' MMMM, h:mm a", 'es').format(_task!.dueDate!),
                        color: _isOverdue ? AppColors.error : AppColors.textSecondary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_task!.description != null && _task!.description!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s6),
              Text(
                'Descripción',
                style: tt.headlineSmall,
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  _task!.description!,
                  style: tt.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            if (_task!.subtasks.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtareas',
                    style: tt.headlineSmall,
                  ),
                  Text(
                    '${_task!.completedSubtasks} de ${_task!.subtasks.length}',
                    style: tt.titleMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.surface2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isCompleted ? AppColors.textDisabled : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
              ...List.generate(_task!.subtasks.length, (index) {
                final subtask = _task!.subtasks[index];
                return _buildSubtaskItem(subtask);
              }),
            ],
            if (!_isDisabled) ...[
              const SizedBox(height: AppSpacing.s6),
              GestureDetector(
                onTap: () => context.push('/tasks/personal/create?parentTaskId=${widget.taskId}'),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withAlpha(76)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.s2),
                      Text(
                        'Agregar subtarea',
                        style: tt.titleMedium?.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: tt.labelLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtaskItem(SubTask subtask) {
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: subtask.isCompleted ? AppColors.surface2 : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: subtask.isCompleted ? AppColors.border : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _isDisabled
                ? null
                : () => _toggleSubtask(subtask.id, !subtask.isCompleted),
            child: AnimatedContainer(
              duration: AppDurations.fast,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: subtask.isCompleted ? AppColors.primary : AppColors.surface,
                border: Border.all(
                  color: subtask.isCompleted
                      ? AppColors.primary
                      : _isDisabled
                          ? AppColors.textDisabled
                          : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: subtask.isCompleted
                  ? const Icon(Icons.check_rounded, size: 14, color: AppColors.textOnPrimary)
                  : null,
            ),
          ),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Text(
              subtask.title,
              style: tt.bodyMedium?.copyWith(
                color: subtask.isCompleted
                    ? AppColors.textDisabled
                    : AppColors.textPrimary,
                decoration: subtask.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          if (!_isDisabled)
            GestureDetector(
              onTap: () async {
                await ref.read(tasksServiceProvider).deleteSubtask(int.parse(subtask.id));
                await _loadTask();
              },
              child: Icon(
                Icons.close,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
