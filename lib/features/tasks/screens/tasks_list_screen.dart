import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/task.dart';
import '../../../shared/widgets/task_card.dart';
import '../../../shared/widgets/empty_state.dart';

class TasksListScreen extends StatefulWidget {
  const TasksListScreen({super.key});

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<TaskPriority> _priorityFilters = {};
  List<TaskModel> _tasks = TaskModel.mockList;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TaskModel> get _filteredTasks {
    var tasks = _tasks;
    switch (_tabController.index) {
      case 1:
        tasks = tasks.where((t) {
          if (t.dueDate == null) return false;
          return t.dueDate!.difference(DateTime.now()).inHours < 24 &&
              t.dueDate!.isAfter(DateTime.now());
        }).toList();
      case 2:
        tasks = tasks.where((t) {
          if (t.dueDate == null) return false;
          final diff = t.dueDate!.difference(DateTime.now());
          return diff.inDays < 7 && diff.inDays >= 0;
        }).toList();
      case 3:
        tasks = tasks.where((t) => t.isOverdue).toList();
    }
    if (_priorityFilters.isNotEmpty) {
      tasks = tasks.where((t) => _priorityFilters.contains(t.priority)).toList();
    }
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis Tareas'),
        actions: [
          IconButton(
            icon: Icon(
              _priorityFilters.isEmpty
                  ? Icons.filter_list_rounded
                  : Icons.filter_list_off_rounded,
              color: _priorityFilters.isEmpty
                  ? AppColors.textPrimary
                  : AppColors.primary,
            ),
            onPressed: _showFilters,
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/search'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            _TabBadge(label: 'Todas', count: _tasks.length),
            _TabBadge(
              label: 'Hoy',
              count: _tasks
                  .where((t) =>
                      t.dueDate != null &&
                      t.dueDate!.difference(DateTime.now()).inHours < 24 &&
                      t.dueDate!.isAfter(DateTime.now()))
                  .length,
              badgeColor: AppColors.primary,
            ),
            const Tab(text: 'Esta semana'),
            _TabBadge(
              label: 'Vencidas',
              count: _tasks.where((t) => t.isOverdue).length,
              badgeColor: AppColors.error,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_priorityFilters.isNotEmpty) _ActiveFiltersBar(
            filters: _priorityFilters,
            onClear: () => setState(() => _priorityFilters.clear()),
          ),
          Expanded(
            child: _filteredTasks.isEmpty
                ? EmptyState(
                    icon: Icons.check_circle_outline_rounded,
                    title: _tabController.index == 3
                        ? '¡Sin tareas vencidas!'
                        : 'Sin tareas pendientes',
                    subtitle: _tabController.index == 3
                        ? 'Excelente, estás al día.'
                        : '¿Agregamos algo nuevo?',
                    actionLabel: 'Nueva tarea',
                    onAction: () => context.push('/tasks/create'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: _filteredTasks.length,
                    itemBuilder: (_, i) {
                      final task = _filteredTasks[i];
                      return TaskCard(
                        task: task,
                        onTap: () => context.push('/tasks/${task.id}'),
                        onComplete: () => setState(() {
                          _tasks.indexWhere((t) => t.id == task.id);
                        }),
                        onDelete: () => setState(() {
                          _tasks.removeWhere((t) => t.id == task.id);
                        }),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/create'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FiltersSheet(
        selected: _priorityFilters,
        onApply: (filters) {
          setState(() => _priorityFilters
            ..clear()
            ..addAll(filters));
        },
      ),
    );
  }
}

class _TabBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color? badgeColor;

  const _TabBadge({required this.label, this.count = 0, this.badgeColor});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: (badgeColor ?? AppColors.textSecondary).withAlpha(38),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: badgeColor ?? AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActiveFiltersBar extends StatelessWidget {
  final Set<TaskPriority> filters;
  final VoidCallback onClear;

  const _ActiveFiltersBar({required this.filters, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface2,
      child: Row(
        children: [
          const Icon(Icons.filter_list_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          ...filters.map((p) => Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _priorityColor(p).withAlpha(38),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _priorityLabel(p),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _priorityColor(p),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
          const Spacer(),
          TextButton(
            onPressed: onClear,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
            ),
            child: const Text('Limpiar', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }

  String _priorityLabel(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.medium:
        return 'Media';
      case TaskPriority.low:
        return 'Baja';
    }
  }
}

class _FiltersSheet extends StatefulWidget {
  final Set<TaskPriority> selected;
  final ValueChanged<Set<TaskPriority>> onApply;

  const _FiltersSheet({required this.selected, required this.onApply});

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late Set<TaskPriority> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.selected};
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Filtrar por prioridad',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: TaskPriority.values.map((p) {
              final isSelected = _selected.contains(p);
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
                  onTap: () => setState(() => isSelected
                      ? _selected.remove(p)
                      : _selected.add(p)),
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
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(height: 6),
                        Text(label,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? color : AppColors.textSecondary,
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onApply({});
                    Navigator.pop(context);
                  },
                  child: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_selected);
                    Navigator.pop(context);
                  },
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
