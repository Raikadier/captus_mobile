import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/tasks_provider.dart';
import '../../../core/providers/categories_provider.dart';
import '../../../models/task.dart';

class PersonalTaskCreateScreen extends ConsumerStatefulWidget {
  final int? taskId;
  final String? parentTaskId;
  final String? initialDate;

  const PersonalTaskCreateScreen({
    super.key,
    this.taskId,
    this.parentTaskId,
    this.initialDate,
  });

  @override
  ConsumerState<PersonalTaskCreateScreen> createState() => _PersonalTaskCreateScreenState();
}

class _PersonalTaskCreateScreenState extends ConsumerState<PersonalTaskCreateScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _subtaskCtrl = TextEditingController();

  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  int? _selectedCategoryId;
  final List<String> _subtasks = [];

  bool _isLoading = false;
  bool _isLoadingTask = false;
  TaskModel? _existingTask;

  bool get _isEditing => widget.taskId != null;
  bool get _isSubtask => widget.parentTaskId != null;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null && !_isEditing && !_isSubtask) {
      final parsed = DateTime.tryParse(widget.initialDate!);
      if (parsed != null) {
        _dueDate = parsed;
      }
    }
    if (_isEditing || _isSubtask) {
      _loadTaskData();
    }
  }

  Future<void> _loadTaskData() async {
    if (_isEditing) {
      setState(() => _isLoadingTask = true);
      final task = await ref.read(tasksServiceProvider).fetchById(widget.taskId!);
      if (task != null && mounted) {
        setState(() {
          _existingTask = task;
          _titleCtrl.text = task.title;
          _descCtrl.text = task.description ?? '';
          _priority = task.priority;
          _dueDate = task.dueDate;
          _selectedCategoryId = task.categoryId;
          _subtasks.addAll(task.subtasks.map((s) => s.title));
        });
      }
      setState(() => _isLoadingTask = false);
    } else if (_isSubtask) {
      final parentId = int.tryParse(widget.parentTaskId!);
      if (parentId != null) {
        setState(() => _isLoadingTask = true);
        final task = await ref.read(tasksServiceProvider).fetchById(parentId);
        if (task != null && mounted) {
          setState(() {
            _existingTask = task;
          });
        }
        setState(() => _isLoadingTask = false);
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _subtaskCtrl.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final value = _subtaskCtrl.text.trim();
    if (value.isNotEmpty) {
      setState(() {
        _subtasks.add(value);
        _subtaskCtrl.clear();
      });
    }
  }

  void _setQuickDate(DateTime date) {
    setState(() {
      _dueDate = DateTime(date.year, date.month, date.day, 23, 59);
    });
  }

  DateTime get _tomorrow {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  DateTime get _weekend {
    final now = DateTime.now();
    final daysUntilSaturday = (6 - now.weekday + 7) % 7;
    final daysToAdd = daysUntilSaturday == 0 ? 7 : daysUntilSaturday;
    return DateTime(now.year, now.month, now.day + daysToAdd);
  }

  DateTime get _nextWeek {
    final now = DateTime.now();
    final daysUntilMonday = (8 - now.weekday) % 7;
    final daysToAdd = daysUntilMonday == 0 ? 7 : daysUntilMonday;
    return DateTime(now.year, now.month, now.day + daysToAdd);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
      );

      if (mounted) {
        setState(() {
          _dueDate = DateTime(
            date.year,
            date.month,
            date.day,
            time?.hour ?? 23,
            time?.minute ?? 59,
          );
        });
      }
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      _showSnackBar('El título es requerido', isError: true);
      return;
    }

    if (!_isSubtask && _dueDate == null) {
      _showSnackBar('La fecha de vencimiento es requerida', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      int priorityId;
      switch (_priority) {
        case TaskPriority.high:
          priorityId = 1;
          break;
        case TaskPriority.medium:
          priorityId = 2;
          break;
        case TaskPriority.low:
          priorityId = 3;
          break;
      }

      if (_isEditing) {
        await ref.read(tasksNotifierProvider.notifier).updateTask(
          widget.taskId!,
          {
            'title': _titleCtrl.text.trim(),
            'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
            'priority_id': priorityId,
            'due_date': _dueDate?.toIso8601String(),
            'category_id': _selectedCategoryId,
          },
        );
      } else {
        await ref.read(tasksNotifierProvider.notifier).create(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          priorityId: priorityId,
          dueDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
          categoryId: _selectedCategoryId,
          parentTaskId: _isSubtask ? int.tryParse(widget.parentTaskId!) : null,
          subtaskTitles: _subtasks.isEmpty ? null : _subtasks,
        );
      }

      if (mounted) {
        _showSuccessSnackBar(
          _isEditing ? 'Tarea actualizada correctamente' : 'Tarea creada correctamente',
        );
        await Future.delayed(const Duration(milliseconds: 500));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesNotifierProvider);

    if (_isLoadingTask) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isSubtask
            ? 'Nueva subtarea'
            : _isEditing
                ? 'Editar tarea'
                : 'Nueva tarea'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _isLoading ? null : () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isSubtask && _existingTask != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.subdirectory_arrow_right,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Subtarea de: ${_existingTask!.title}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            TextField(
              controller: _titleCtrl,
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: _isSubtask ? 'Título de la subtarea' : 'Título de la tarea',
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
            if (!_isSubtask) ...[
              Text(
                'Prioridad',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
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
              Text(
                'Fecha de vencimiento',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
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
                      color: _dueDate != null ? AppColors.primary : AppColors.border,
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
                      Expanded(
                        child: Text(
                          _dueDate != null
                              ? DateFormat("d 'de' MMMM, h:mm a", 'es').format(_dueDate!)
                              : 'Seleccionar fecha',
                          style: GoogleFonts.inter(
                            color: _dueDate != null
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (_dueDate != null)
                        GestureDetector(
                          onTap: () => setState(() => _dueDate = null),
                          child: Icon(Icons.close_rounded, size: 18),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _QuickDateChip(
                      label: 'Mañana',
                      icon: Icons.wb_sunny_outlined,
                      isSelected: _dueDate != null && _dueDate!.year == _tomorrow.year && _dueDate!.month == _tomorrow.month && _dueDate!.day == _tomorrow.day,
                      onTap: () => _setQuickDate(_tomorrow),
                    ),
                    const SizedBox(width: 8),
                    _QuickDateChip(
                      label: 'Fin de semana',
                      icon: Icons.weekend_outlined,
                      isSelected: _dueDate != null && _dueDate!.year == _weekend.year && _dueDate!.month == _weekend.month && _dueDate!.day == _weekend.day,
                      onTap: () => _setQuickDate(_weekend),
                    ),
                    const SizedBox(width: 8),
                    _QuickDateChip(
                      label: 'Próxima semana',
                      icon: Icons.calendar_view_week_outlined,
                      isSelected: _dueDate != null && _dueDate!.year == _nextWeek.year && _dueDate!.month == _nextWeek.month && _dueDate!.day == _nextWeek.day,
                      onTap: () => _setQuickDate(_nextWeek),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Categoría',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              categoriesAsync.when(
                data: (categories) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: _selectedCategoryId,
                      dropdownColor: AppColors.surface,
                      hint: Text(
                        'Sin categoría',
                        style: GoogleFonts.inter(color: AppColors.textSecondary),
                      ),
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                      ),
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            'Sin categoría',
                            style: GoogleFonts.inter(color: AppColors.textSecondary),
                          ),
                        ),
                        ...categories.map((c) => DropdownMenuItem<int?>(
                          value: c.id,
                          child: Text(c.name),
                        )),
                      ],
                      onChanged: (val) => setState(() => _selectedCategoryId = val),
                    ),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Error al cargar categorías'),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'Descripción',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _descCtrl,
              maxLines: 4,
              style: GoogleFonts.inter(),
              decoration: InputDecoration(
                hintText: 'Agrega una descripción...',
                hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            if (!_isSubtask) ...[
              const SizedBox(height: 24),
              Text(
                'Subtareas',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              if (_subtasks.isNotEmpty) ...[
                ...List.generate(_subtasks.length, (index) => _buildSubtaskItem(index)),
                const SizedBox(height: 10),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _subtaskCtrl,
                      style: GoogleFonts.inter(),
                      decoration: InputDecoration(
                        hintText: 'Agregar subtarea...',
                        hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.surface2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      onFieldSubmitted: (_) => _addSubtask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _addSubtask,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtaskItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _subtasks[index],
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _subtasks.removeAt(index)),
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

class _QuickDateChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickDateChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}