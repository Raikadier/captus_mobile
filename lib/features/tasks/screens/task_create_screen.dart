import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/local_notification_service.dart';
import '../../../core/utils/app_errors.dart';
import '../../../models/task.dart';
import '../../../shared/widgets/captus_pressable.dart';

enum AcademicItemType {
  task,
  evaluation,
}

class TaskCreateScreen extends StatefulWidget {
  final String? taskId;
  final String? courseId;

  const TaskCreateScreen({
    super.key,
    this.taskId,
    this.courseId,
  });

  @override
  State<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends State<TaskCreateScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _subtaskCtrl = TextEditingController();

  AcademicItemType _type = AcademicItemType.task;
  TaskPriority _priority = TaskPriority.medium;

  DateTime? _dueDate;
  String? _selectedCourseId;
  String? _selectedGroupId;

  bool _isSaving = false;
  bool _isLoadingCourses = false;
  bool _isLoadingGroups = false;

  final List<String> _subtasks = [];
  final List<_CourseOption> _courses = [];
  final List<_CourseGroupOption> _groups = [];

  bool get _isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.courseId;
    _loadCourses();
    if (_isEditing) _loadExistingTask();
  }

  Future<void> _loadExistingTask() async {
    final id = widget.taskId;
    if (id == null) return;
    try {
      final res = await ApiClient.instance.get<dynamic>('/assignments/$id');
      final row = res.data;
      if (row == null || row is! Map || !mounted) return;
      setState(() {
        _titleCtrl.text = row['title']?.toString() ?? '';
        _descCtrl.text = row['description']?.toString() ?? '';
        if (row['due_date'] != null) {
          _dueDate = DateTime.tryParse(row['due_date'].toString());
        }
        if (row['course_id'] != null) {
          _selectedCourseId = row['course_id'].toString();
        }
      });
    } catch (_) {
      // No-op: form stays blank, user can fill in manually
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _subtaskCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoadingCourses = true);

    try {
      final res = await ApiClient.instance.get<dynamic>('/courses/teacher');
      final response = res.data;

      final loadedCourses = (response as List).map((row) {
        final map = row as Map<String, dynamic>;

        return _CourseOption(
          id: map['id'].toString(),
          name: (map['title'] ?? map['name'] ?? 'Materia sin nombre').toString(),
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        _courses
          ..clear()
          ..addAll(loadedCourses);
      });

      if (_selectedCourseId != null) {
        await _loadGroupsByCourse(_selectedCourseId!);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e, fallback: 'No se pudieron cargar las materias. Intenta de nuevo.'))),
      );
    } finally {
      if (mounted) setState(() => _isLoadingCourses = false);
    }
  }

  Future<void> _loadGroupsByCourse(String courseId) async {
    if (courseId.isEmpty) {
      setState(() {
        _groups.clear();
        _selectedGroupId = null;
      });
      return;
    }

    setState(() {
      _isLoadingGroups = true;
      _groups.clear();
      _selectedGroupId = null;
    });

    try {
      final res = await ApiClient.instance
          .get<dynamic>('/groups/course/$courseId');
      final response = res.data;

      final loadedGroups = (response as List).map((row) {
        final map = row as Map<String, dynamic>;

        final id = map['id'].toString();
        final name = (map['name'] ?? 'Grupo $id').toString();

        return _CourseGroupOption(id: id, name: name);
      }).toList();

      if (!mounted) return;

      setState(() {
        _groups
          ..clear()
          ..addAll(loadedGroups);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e, fallback: 'No se pudieron cargar los grupos. Intenta de nuevo.'))),
      );
    } finally {
      if (mounted) setState(() => _isLoadingGroups = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      restorationId: 'task_create_screen',
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar actividad' : 'Nueva actividad'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cerrar',
          onPressed: _isSaving ? null : () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: Text(_isSaving ? 'Guardando...' : 'Guardar'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              style: Theme.of(context).textTheme.displaySmall,
              decoration: InputDecoration(
                hintText: _type == AcademicItemType.task
                    ? 'Título de la tarea'
                    : 'Título de la evaluación',
              ),
              maxLines: 2,
            ),
            const Divider(color: AppColors.border),
            const SizedBox(height: AppSpacing.s4),

            Text('Tipo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s2 + 2),
            Row(
              children: [
                _buildTypeButton(
                  label: 'Tarea',
                  icon: Icons.assignment_outlined,
                  type: AcademicItemType.task,
                ),
                const SizedBox(width: AppSpacing.s2 + 2),
                _buildTypeButton(
                  label: 'Evaluación',
                  icon: Icons.school_outlined,
                  type: AcademicItemType.evaluation,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.s6),
            Text('Prioridad', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s2 + 2),
            Row(
              children: TaskPriority.values.map((p) {
                final isSelected = _priority == p;

                final color = p == TaskPriority.high
                    ? AppColors.priorityHigh
                    : p == TaskPriority.medium
                        ? AppColors.priorityMedium
                        : AppColors.priorityLow;

                final label = p == TaskPriority.high
                    ? 'Alta'
                    : p == TaskPriority.medium
                        ? 'Media'
                        : 'Baja';

                return Expanded(
                  child: CaptusPressable(
                    onTap: () => setState(() => _priority = p),
                    child: AnimatedContainer(
                      duration: AppDurations.fast,
                      margin: const EdgeInsets.only(right: AppSpacing.s2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withAlpha(AppAlpha.a15) : AppColors.surface2,
                        borderRadius: BorderRadius.circular(AppRadius.r4),
                        border: Border.all(
                          color: isSelected ? color : AppColors.border,
                          width: isSelected ? 2 : 0.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isSelected ? color : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.s6),
            Text('Fecha límite', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s2 + 2),
            CaptusPressable(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.s3 + 2),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(AppRadius.r5),
                  border: Border.all(
                    color: _dueDate != null ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18),
                    const SizedBox(width: AppSpacing.s2 + 2),
                    Expanded(
                      child: Text(
                        _dueDate != null
                            ? DateFormat("d 'de' MMMM, h:mm a", 'es').format(_dueDate!)
                            : 'Sin fecha límite',
                      ),
                    ),
                    if (_dueDate != null)
                      CaptusPressable(
                        onTap: () => setState(() => _dueDate = null),
                        child: const Icon(Icons.close_rounded, size: 16),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.s6),
            Text('Materia', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s2 + 2),
            DropdownButtonFormField<String>(
              value: _selectedCourseId,
              hint: Text(
                _isLoadingCourses
                    ? 'Cargando tus materias...'
                    : _courses.isEmpty
                        ? 'No tienes materias asignadas'
                        : 'Selecciona una materia',
              ),
              decoration: const InputDecoration(),
              items: _courses
                  .map((course) => DropdownMenuItem(
                        value: course.id,
                        child: Text(course.name),
                      ))
                  .toList(),
              onChanged: _isLoadingCourses || _courses.isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        _selectedCourseId = value;
                        _selectedGroupId = null;
                        _groups.clear();
                      });

                      if (value != null) _loadGroupsByCourse(value);
                    },
            ),

            const SizedBox(height: AppSpacing.s6),
            Text('Grupo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s2 + 2),
            DropdownButtonFormField<String>(
              value: _selectedGroupId,
              hint: Text(
                _selectedCourseId == null
                    ? 'Primero selecciona una materia'
                    : _isLoadingGroups
                        ? 'Cargando grupos...'
                        : _groups.isEmpty
                            ? 'No hay grupos para esta materia'
                            : 'Selecciona el grupo',
              ),
              decoration: const InputDecoration(),
              items: _groups
                  .map((group) => DropdownMenuItem(
                        value: group.id,
                        child: Text(group.name),
                      ))
                  .toList(),
              onChanged: _selectedCourseId == null || _isLoadingGroups || _groups.isEmpty
                  ? null
                  : (value) => setState(() => _selectedGroupId = value),
            ),

            const SizedBox(height: AppSpacing.s6),
            Text('Descripción', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s2 + 2),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Agrega detalles...'),
            ),

            const SizedBox(height: AppSpacing.s6),
            Text('Subtareas / instrucciones', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s2 + 2),
            ..._subtasks.map((s) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(s),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Cerrar',
                    onPressed: () => setState(() => _subtasks.remove(s)),
                  ),
                )),
            TextFormField(
              controller: _subtaskCtrl,
              decoration: const InputDecoration(
                hintText: 'Agregar instrucción...',
                prefixIcon: Icon(Icons.add_rounded),
              ),
              onFieldSubmitted: _addSubtask,
            ),
            const SizedBox(height: AppSpacing.s20),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required IconData icon,
    required AcademicItemType type,
  }) {
    final isSelected = _type == type;

    return Expanded(
      child: CaptusPressable(
        onTap: () => setState(() => _type = type),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withAlpha(AppAlpha.a15) : AppColors.surface2,
            borderRadius: BorderRadius.circular(AppRadius.r5),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.6 : 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(height: AppSpacing.s1),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
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
      setState(() => _dueDate = date.copyWith(hour: 23, minute: 59));
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;

    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un título')),
      );
      return;
    }

    if (_selectedCourseId == null || _selectedGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona materia y grupo')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Use Express API — enforces teacher-owns-course + notifies students
      await ApiClient.instance.post<dynamic>('/assignments', data: {
        'course_id': _selectedCourseId,
        'course_group_id': _selectedGroupId,
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        'due_date': _dueDate?.toIso8601String(),
        'is_group_assignment': true,
        'assignment_type': _type == AcademicItemType.task ? 'task' : 'evaluation',
        'priority': _priority.name,
      });

      if (_dueDate != null) {
        final reminderDate = _dueDate!.subtract(const Duration(hours: 1));

        if (reminderDate.isAfter(DateTime.now())) {
          await LocalNotificationService.instance.scheduleTaskReminder(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: _type == AcademicItemType.task
                ? 'Tarea asignada'
                : 'Evaluación asignada',
            body: '${_titleCtrl.text.trim()} vence pronto',
            scheduledDate: reminderDate,
          );
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actividad asignada correctamente')),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e, fallback: 'No se pudo guardar. Intenta de nuevo.'))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _CourseOption {
  final String id;
  final String name;

  const _CourseOption({
    required this.id,
    required this.name,
  });
}

class _CourseGroupOption {
  final String id;
  final String name;

  const _CourseGroupOption({
    required this.id,
    required this.name,
  });
}
