import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/courses_provider.dart';
import '../../../core/providers/tasks_provider.dart';
import '../../../models/task.dart';

class TaskCreateScreen extends ConsumerStatefulWidget {
  final String? taskId;
  final String? courseId;

  const TaskCreateScreen({
    super.key,
    this.taskId,
    this.courseId,
  });

  @override
  ConsumerState<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends ConsumerState<TaskCreateScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _subtaskCtrl = TextEditingController();

  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  String? _selectedCourseId;
  final List<String> _subtasks = [];
  bool _isLoading = false;
  bool _taskNotFound = false;

  bool get _isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.courseId;

    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final tasks = await ref.read(tasksNotifierProvider.future);

        if (!mounted) return;

        if (tasks.isEmpty) {
          setState(() => _taskNotFound = true);
          return;
        }

        TaskModel? task;
        for (final item in tasks) {
          if (item.id == widget.taskId) {
            task = item;
            break;
          }
        }

        if (task == null) {
          setState(() => _taskNotFound = true);
          return;
        }

        setState(() {
          _titleCtrl.text = task!.title;
          _descCtrl.text = task.description ?? '';
          _priority = task.priority;
          _dueDate = task.dueDate;
          _selectedCourseId = task.courseId;
          _subtasks
            ..clear()
            ..addAll(task.subtasks.map((s) => s.title));
        });
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _subtaskCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);

    if (_taskNotFound) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Tarea no encontrada'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tarea no encontrada',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'La tarea que intentas editar no existe o ya no está disponible.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar tarea' : 'Nueva tarea'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Guardar'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Título de la tarea',
                hintStyle: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDisabled,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: 2,
            ),
            const Divider(color: AppColors.border),
            const SizedBox(height: 16),
            Text('Prioridad', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Row(
              children: TaskPriority.values.map((p) {
                final isSelected = _priority == p;
                final color = p == TaskPriority.high
                    ? AppColors.priorityHigh
                    : p == TaskPriority.medium
                        ? AppColors.priorityMedium
                        : AppColors.priorityLow;

                final emoji = p == TaskPriority.high
                    ? '🔴'
                    : p == TaskPriority.medium
                        ? '🟡'
                        : '🟢';

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withAlpha(38)
                            : AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? color : AppColors.border,
                          width: isSelected ? 2 : 0.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(
                            p.label,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected ? color : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Fecha límite',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        _dueDate != null ? AppColors.primary : AppColors.border,
                    width: _dueDate != null ? 1.5 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: _dueDate != null
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _dueDate != null
                          ? DateFormat("d 'de' MMMM, h:mm a", 'es')
                              .format(_dueDate!)
                          : 'Sin fecha límite',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _dueDate != null
                            ? AppColors.textPrimary
                            : AppColors.textDisabled,
                      ),
                    ),
                    const Spacer(),
                    if (_dueDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _dueDate = null),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Materia', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            coursesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Error al cargar materias: $err'),
              data: (courses) {
                return DropdownButtonFormField<String>(
                  value: courses.any((c) => c.id == _selectedCourseId)
                      ? _selectedCourseId
                      : null,
                  hint: const Text('Selecciona una materia'),
                  dropdownColor: AppColors.surface,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Sin materia'),
                    ),
                    ...courses.map(
                      (c) => DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedCourseId = v),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Descripción (opcional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Agrega detalles...',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Subtareas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _generateWithAI,
                  icon: const Text('🤖', style: TextStyle(fontSize: 14)),
                  label: const Text(
                    'Generar con IA',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._subtasks.asMap().entries.map(
                  (e) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.drag_handle_rounded,
                          size: 18,
                          color: AppColors.textDisabled,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            e.value,
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(
                            () => _subtasks.removeAt(e.key),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            TextFormField(
              controller: _subtaskCtrl,
              decoration: const InputDecoration(
                hintText: 'Agregar subtarea...',
                prefixIcon: Icon(Icons.add_rounded),
              ),
              onFieldSubmitted: _addSubtask,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _addSubtask(String value) {
    if (value.trim().isNotEmpty) {
      setState(() {
        _subtasks.add(value.trim());
        _subtaskCtrl.clear();
      });
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
      );

      if (time != null) {
        setState(
          () => _dueDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          ),
        );
      }
    }
  }

  void _generateWithAI() {
    if (_titleCtrl.text.trim().isNotEmpty) {
      setState(() {
        _subtasks.addAll([
          'Investigar el tema',
          'Hacer un borrador',
          'Revisar y corregir',
          'Entregar',
        ]);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subtareas generadas por IA ✓')),
      );
    }
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un título')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = ref.read(currentUserProvider)?.id ?? '';

      final payload = {
        'title': title,
        'description': _descCtrl.text.trim(),
        'priority': _priority.name,
        'dueDate': _dueDate?.toIso8601String(),
        'courseId': _selectedCourseId,
        'userId': userId,
        'subTasks': _subtasks.map((s) => {'title': s}).toList(),
      };

      if (_isEditing) {
        await ref
            .read(tasksNotifierProvider.notifier)
            .updateTask(widget.taskId!, payload);
      } else {
        await ref.read(tasksNotifierProvider.notifier).create(payload);
      }

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}