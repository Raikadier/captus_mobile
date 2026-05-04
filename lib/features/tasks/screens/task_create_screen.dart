import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/task.dart';
import '../../../models/course.dart';
import '../../../core/services/local_notification_service.dart';

class TaskCreateScreen extends StatefulWidget {
  final String? taskId;
  final String? courseId;

  const TaskCreateScreen({super.key, this.taskId, this.courseId});

  @override
  State<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends State<TaskCreateScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _subtaskCtrl = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  String? _selectedCourseId;
  final List<String> _subtasks = [];

  bool get _isEditing => widget.taskId != null;

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.courseId;
    if (_isEditing) {
      final task = TaskModel.mockList.firstWhere((t) => t.id == widget.taskId!,
          orElse: () => TaskModel.mockList.first);
      _titleCtrl.text = task.title;
      _descCtrl.text = task.description ?? '';
      _priority = task.priority;
      _dueDate = task.dueDate;
      _selectedCourseId = task.courseId;
      _subtasks.addAll(task.subtasks.map((s) => s.title));
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar tarea' : 'Nueva tarea'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
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
                  fontSize: 20, fontWeight: FontWeight.w600),
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

            // Priority
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
                final emoji =
                    p == TaskPriority.high ? '🔴' : p == TaskPriority.medium ? '🟡' : '🟢';
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withAlpha(38) : AppColors.surface2,
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
                            label,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? color : AppColors.textSecondary,
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

            // Due date
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
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Quick date shortcuts
            Row(
              children: ['Hoy', 'Mañana', 'Esta semana'].map((label) {
                DateTime date;
                if (label == 'Hoy') {
                  date = DateTime.now().copyWith(hour: 23, minute: 59);
                } else if (label == 'Mañana') {
                  date = DateTime.now()
                      .add(const Duration(days: 1))
                      .copyWith(hour: 23, minute: 59);
                } else {
                  date = DateTime.now()
                      .add(Duration(days: 7 - DateTime.now().weekday))
                      .copyWith(hour: 23, minute: 59);
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(label),
                    onPressed: () => setState(() => _dueDate = date),
                    backgroundColor: AppColors.surface2,
                    labelStyle: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Course
            Text('Materia', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCourseId,
              hint: const Text('Selecciona una materia'),
              dropdownColor: AppColors.surface,
              decoration: const InputDecoration(),
              items: [
                const DropdownMenuItem(value: null, child: Text('Sin materia')),
                ...CourseModel.mockList.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    )),
              ],
              onChanged: (v) => setState(() => _selectedCourseId = v),
            ),
            const SizedBox(height: 24),

            // Description
            Text('Descripción (opcional)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Agrega detalles...',
              ),
            ),
            const SizedBox(height: 24),

            // Subtasks
            Row(
              children: [
                Text('Subtareas',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton.icon(
                  onPressed: _generateWithAI,
                  icon: const Text('🤖', style: TextStyle(fontSize: 14)),
                  label: const Text('Generar con IA',
                      style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._subtasks.asMap().entries.map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.drag_handle_rounded,
                          size: 18, color: AppColors.textDisabled),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(e.value,
                              style: GoogleFonts.inter(fontSize: 14))),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _subtasks.removeAt(e.key)),
                        child: const Icon(Icons.close_rounded,
                            size: 16, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _subtaskCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Agregar subtarea...',
                      prefixIcon: Icon(Icons.add_rounded),
                    ),
                    onFieldSubmitted: _addSubtask,
                  ),
                ),
              ],
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
      builder: (_, child) => Theme(
        data: Theme.of(context),
        child: child!,
      ),
    );
    if (date != null && mounted) {
      setState(() => _dueDate = date.copyWith(hour: 23, minute: 59));
    }
  }

  void _generateWithAI() {
    // Placeholder: show mock subtasks generated by AI
    if (_titleCtrl.text.isNotEmpty) {
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

  void _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un título para la tarea')),
      );
      return;
    }

    // 🔔 PROGRAMAR NOTIFICACIÓN
    if (_dueDate != null) {
      final reminderDate = _dueDate!.subtract(const Duration(hours: 1));

      await LocalNotificationService.instance.scheduleTaskReminder(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: 'Tarea pendiente',
        body: _titleCtrl.text,
        scheduledDate: reminderDate,
      );
    }

    FocusScope.of(context).unfocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }
}
