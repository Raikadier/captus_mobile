import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/task.dart';
import '../../../shared/widgets/countdown_chip.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TaskModel _task;

  @override
  void initState() {
    super.initState();
    _task = TaskModel.mockList.firstWhere(
      (t) => t.id == widget.taskId,
      orElse: () => TaskModel.mockList.first,
    );
  }

  Color get _priorityColor {
    switch (_task.priority) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }

  String get _priorityLabel {
    switch (_task.priority) {
      case TaskPriority.high:
        return 'Prioridad Alta';
      case TaskPriority.medium:
        return 'Prioridad Media';
      case TaskPriority.low:
        return 'Prioridad Baja';
    }
  }

  void _toggleSubtask(int index) {
    setState(() {
      final updated = _task.subtasks[index].copyWith(
        isCompleted: !_task.subtasks[index].isCompleted,
      );
      final newList = List<SubTask>.from(_task.subtasks);
      newList[index] = updated;
      _task = TaskModel(
        id: _task.id,
        title: _task.title,
        description: _task.description,
        priority: _task.priority,
        status: _task.status,
        dueDate: _task.dueDate,
        courseId: _task.courseId,
        courseName: _task.courseName,
        subtasks: newList,
        createdAt: _task.createdAt,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _priorityColor.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _priorityLabel,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _priorityColor,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            color: AppColors.surface,
            onSelected: (v) {
              if (v == 'edit') context.push('/tasks/${_task.id}/edit');
              if (v == 'delete') _confirmDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Editar')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Eliminar', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _task.title,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Metadata row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_task.courseName != null)
                  _MetaChip(
                    icon: Icons.school_outlined,
                    label: _task.courseName!,
                  ),
                if (_task.dueDate != null)
                  CountdownChip(dueDate: _task.dueDate!),
              ],
            ),

            if (_task.description != null) ...[
              const SizedBox(height: 20),
              Text(
                'Descripción',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _task.description!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ],

            if (_task.subtasks.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'SUBTAREAS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_task.completedSubtasks}/${_task.subtasks.length}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _task.subtasks.isEmpty
                    ? 0
                    : _task.completedSubtasks / _task.subtasks.length,
                minHeight: 4,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 12),
              ...List.generate(_task.subtasks.length, (i) {
                final sub = _task.subtasks[i];
                return GestureDetector(
                  onTap: () => _toggleSubtask(i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: sub.isCompleted
                                ? AppColors.primary
                                : Colors.transparent,
                            border: Border.all(
                              color: sub.isCompleted
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: sub.isCompleted
                              ? const Icon(Icons.check_rounded,
                                  size: 12, color: Colors.black)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            sub.title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: sub.isCompleted
                                  ? AppColors.textDisabled
                                  : AppColors.textPrimary,
                              decoration: sub.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],

            const SizedBox(height: 24),
            // AI Help button
            OutlinedButton.icon(
              onPressed: () => context.push('/ai'),
              icon: const Text('🤖', style: TextStyle(fontSize: 16)),
              label: const Text('Pedir ayuda al asistente IA'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {},
            child: Text(
              _task.status == TaskStatus.completed
                  ? 'Completada ✓'
                  : 'Marcar como completada',
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar tarea'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${_task.title}"?',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('Eliminar',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
