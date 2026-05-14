import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/local_notification_service.dart';
import '../../../core/utils/app_errors.dart';
import '../../../models/task.dart';

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
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await Supabase.instance.client
          .from('courses')
          .select('id,title')
          .eq('teacher_id', user.id)
          .order('title', ascending: true);

      final loadedCourses = (response as List).map((row) {
        final map = row as Map<String, dynamic>;

        return _CourseOption(
          id: map['id'].toString(),
          name: (map['title'] ?? 'Materia sin nombre').toString(),
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
    final parsedCourseId = int.tryParse(courseId);

    if (parsedCourseId == null) {
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
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final course = await Supabase.instance.client
          .from('courses')
          .select('id,teacher_id')
          .eq('id', parsedCourseId)
          .eq('teacher_id', user.id)
          .maybeSingle();

      if (course == null) {
        throw Exception('No tienes permiso sobre esta materia');
      }

      final response = await Supabase.instance.client
          .from('course_groups')
          .select('id,name')
          .eq('course_id', parsedCourseId)
          .order('id', ascending: true);

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar actividad' : 'Nueva actividad'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: _type == AcademicItemType.task
                    ? 'Título de la tarea'
                    : 'Título de la evaluación',
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

            Text('Tipo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildTypeButton(
                  label: 'Tarea',
                  icon: Icons.assignment_outlined,
                  type: AcademicItemType.task,
                ),
                const SizedBox(width: 10),
                _buildTypeButton(
                  label: 'Evaluación',
                  icon: Icons.school_outlined,
                  type: AcademicItemType.evaluation,
                ),
              ],
            ),

            const SizedBox(height: 24),
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

                final label = p == TaskPriority.high
                    ? 'Alta'
                    : p == TaskPriority.medium
                        ? 'Media'
                        : 'Baja';

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withAlpha(38) : AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? color : AppColors.border,
                          width: isSelected ? 2 : 0.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: GoogleFonts.inter(
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

            const SizedBox(height: 24),
            Text('Fecha límite', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _dueDate != null ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _dueDate != null
                            ? DateFormat("d 'de' MMMM, h:mm a", 'es').format(_dueDate!)
                            : 'Sin fecha límite',
                      ),
                    ),
                    if (_dueDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _dueDate = null),
                        child: const Icon(Icons.close_rounded, size: 16),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text('Materia', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
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

            const SizedBox(height: 24),
            Text('Grupo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
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

            const SizedBox(height: 24),
            Text('Descripción', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Agrega detalles...'),
            ),

            const SizedBox(height: 24),
            Text('Subtareas / instrucciones', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            ..._subtasks.map((s) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(s),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
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
            const SizedBox(height: 80),
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
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withAlpha(38) : AppColors.surface2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.6 : 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.inter(
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

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario no autenticado')),
      );
      return;
    }

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

    final courseId = int.tryParse(_selectedCourseId!);
    final courseGroupId = int.tryParse(_selectedGroupId!);

    if (courseId == null || courseGroupId == null) return;

    setState(() => _isSaving = true);

    try {
      final course = await Supabase.instance.client
          .from('courses')
          .select('id,teacher_id')
          .eq('id', courseId)
          .eq('teacher_id', user.id)
          .maybeSingle();

      if (course == null) {
        throw Exception('Solo el docente dueño del curso puede asignar actividades');
      }

      await Supabase.instance.client.from('course_assignments').insert({
        'course_id': courseId,
        'course_group_id': courseGroupId,
        'teacher_id': user.id,
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