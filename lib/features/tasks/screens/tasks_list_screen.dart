import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/tasks_provider.dart';
import '../../../models/task.dart';
import '../../../shared/widgets/task_card.dart';
import '../../../shared/widgets/empty_state.dart';

// Filtros de tiempo (chips horizontales)
enum _TimeFilter { todas, hoy, semana, porCurso }

class TasksListScreen extends ConsumerStatefulWidget {
  const TasksListScreen({super.key});

  @override
  ConsumerState<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends ConsumerState<TasksListScreen> {
  _TimeFilter _activeFilter = _TimeFilter.todas;
  final Set<TaskPriority> _priorityFilters = {};

  List<TaskModel> _applyFilters(List<TaskModel> all) {
    var tasks = all.where((t) => !t.completed).toList();

    switch (_activeFilter) {
      case _TimeFilter.hoy:
        tasks = tasks.where((t) {
          if (t.dueDate == null) return false;
          final diff = t.dueDate!.difference(DateTime.now());
          return diff.inHours < 24 && t.dueDate!.isAfter(DateTime.now());
        }).toList();
      case _TimeFilter.semana:
        tasks = tasks.where((t) {
          if (t.dueDate == null) return false;
          final diff = t.dueDate!.difference(DateTime.now());
          return diff.inDays < 7 && diff.inDays >= 0;
        }).toList();
      case _TimeFilter.porCurso:
        tasks.sort((a, b) =>
            (a.courseName ?? '').compareTo(b.courseName ?? ''));
      case _TimeFilter.todas:
        break;
    }

    if (_priorityFilters.isNotEmpty) {
      tasks = tasks.where((t) => _priorityFilters.contains(t.priority)).toList();
    }
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksNotifierProvider);

    return tasksAsync.when(
      loading: () => const _TasksLoadingSkeleton(),
      error: (err, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 48, color: AppColors.textDisabled),
              const SizedBox(height: 12),
              Text('No se pudieron cargar las tareas',
                  style: GoogleFonts.inter(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(tasksNotifierProvider.notifier).refresh(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
      data: (allTasks) {
        final filtered = _applyFilters(allTasks);
        final todayCount = allTasks
            .where((t) =>
                !t.completed &&
                t.dueDate != null &&
                t.dueDate!.difference(DateTime.now()).inHours < 24 &&
                t.dueDate!.isAfter(DateTime.now()))
            .length;
        final overdueCount = allTasks.where((t) => t.isOverdue).length;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () =>
                ref.read(tasksNotifierProvider.notifier).refresh(),
            child: CustomScrollView(
              slivers: [
                // ── AppBar ─────────────────────────────────────────────────
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppColors.surface,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  titleSpacing: 16,
                  title: Text(
                    'Mis tareas',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  actions: [
                    // Filtro de prioridad
                    IconButton(
                      icon: Icon(
                        _priorityFilters.isEmpty
                            ? Icons.tune_rounded
                            : Icons.tune_rounded,
                        color: _priorityFilters.isEmpty
                            ? AppColors.textSecondary
                            : AppColors.primary,
                      ),
                      onPressed: _showFilters,
                    ),
                    // Buscar
                    IconButton(
                      icon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => context.push('/search'),
                    ),
                    // Nueva tarea
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => context.push('/tasks/create'),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1),
                    child: Container(color: AppColors.border, height: 1),
                  ),
                ),

                // ── Chips de filtro ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _FilterChipsRow(
                    active: _activeFilter,
                    todayCount: todayCount,
                    overdueCount: overdueCount,
                    onChanged: (f) => setState(() => _activeFilter = f),
                  ),
                ),

                // ── Filtros activos de prioridad ───────────────────────────
                if (_priorityFilters.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _ActiveFiltersBar(
                      filters: _priorityFilters,
                      onClear: () =>
                          setState(() => _priorityFilters.clear()),
                    ),
                  ),

                // ── Lista de tareas ────────────────────────────────────────
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.check_circle_outline_rounded,
                      title: _activeFilter == _TimeFilter.todas
                          ? 'Sin tareas pendientes'
                          : '¡Todo al día!',
                      subtitle: '¿Agregamos algo nuevo?',
                      actionLabel: 'Nueva tarea',
                      onAction: () => context.push('/tasks/create'),
                    ),
                  )
                else
                  _activeFilter == _TimeFilter.todas
                      ? _GroupedTaskList(
                          tasks: filtered,
                          allTasks: allTasks,
                          onTap: (t) => context.push('/tasks/${t.id}'),
                          onComplete: (t) => ref
                              .read(tasksNotifierProvider.notifier)
                              .complete(t.id),
                          onDelete: (t) => ref
                              .read(tasksNotifierProvider.notifier)
                              .delete(t.id),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.only(top: 8, bottom: 100),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, i) => TaskCard(
                                task: filtered[i],
                                onTap: () =>
                                    context.push('/tasks/${filtered[i].id}'),
                                onComplete: () => ref
                                    .read(tasksNotifierProvider.notifier)
                                    .complete(filtered[i].id),
                                onDelete: () => ref
                                    .read(tasksNotifierProvider.notifier)
                                    .delete(filtered[i].id),
                              ),
                              childCount: filtered.length,
                            ),
                          ),
                        ),
              ],
            ),
          ),
        );
      },
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

// ── Chips de filtro horizontal ────────────────────────────────────────────────

class _FilterChipsRow extends StatelessWidget {
  final _TimeFilter active;
  final int todayCount;
  final int overdueCount;
  final ValueChanged<_TimeFilter> onChanged;

  const _FilterChipsRow({
    required this.active,
    required this.todayCount,
    required this.overdueCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Chip(
              label: 'Todas',
              isActive: active == _TimeFilter.todas,
              onTap: () => onChanged(_TimeFilter.todas),
            ),
            const SizedBox(width: 8),
            _Chip(
              label: 'Hoy',
              count: todayCount,
              isActive: active == _TimeFilter.hoy,
              onTap: () => onChanged(_TimeFilter.hoy),
            ),
            const SizedBox(width: 8),
            _Chip(
              label: 'Esta semana',
              isActive: active == _TimeFilter.semana,
              onTap: () => onChanged(_TimeFilter.semana),
            ),
            const SizedBox(width: 8),
            _Chip(
              label: 'Por curso',
              isActive: active == _TimeFilter.porCurso,
              onTap: () => onChanged(_TimeFilter.porCurso),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isActive;
  final int? count;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withAlpha(60)
                      : AppColors.error.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : AppColors.error,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Lista agrupada (Hoy / Esta semana / sin fecha) ────────────────────────────

class _GroupedTaskList extends StatelessWidget {
  final List<TaskModel> tasks;
  final List<TaskModel> allTasks;
  final ValueChanged<TaskModel> onTap;
  final ValueChanged<TaskModel> onComplete;
  final ValueChanged<TaskModel> onDelete;

  const _GroupedTaskList({
    required this.tasks,
    required this.allTasks,
    required this.onTap,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final today = tasks.where((t) {
      if (t.dueDate == null) return false;
      final diff = t.dueDate!.difference(DateTime.now());
      return diff.inHours < 24 && t.dueDate!.isAfter(DateTime.now());
    }).toList();

    final thisWeek = tasks.where((t) {
      if (t.dueDate == null) return false;
      final diff = t.dueDate!.difference(DateTime.now());
      return diff.inHours >= 24 && diff.inDays < 7;
    }).toList();

    final overdue = allTasks.where((t) => t.isOverdue).toList();

    final rest = tasks.where((t) {
      if (t.dueDate == null) return true;
      final diff = t.dueDate!.difference(DateTime.now());
      return diff.inDays >= 7;
    }).toList();

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 100),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          if (overdue.isNotEmpty) ...[
            _GroupHeader(label: 'Vencidas', color: AppColors.error),
            ...overdue.map((t) => TaskCard(
                  task: t,
                  onTap: () => onTap(t),
                  onComplete: () => onComplete(t),
                  onDelete: () => onDelete(t),
                )),
          ],
          if (today.isNotEmpty) ...[
            const _GroupHeader(label: 'Hoy'),
            ...today.map((t) => TaskCard(
                  task: t,
                  onTap: () => onTap(t),
                  onComplete: () => onComplete(t),
                  onDelete: () => onDelete(t),
                )),
          ],
          if (thisWeek.isNotEmpty) ...[
            const _GroupHeader(label: 'Esta semana'),
            ...thisWeek.map((t) => TaskCard(
                  task: t,
                  onTap: () => onTap(t),
                  onComplete: () => onComplete(t),
                  onDelete: () => onDelete(t),
                )),
          ],
          if (rest.isNotEmpty) ...[
            const _GroupHeader(label: 'Próximamente'),
            ...rest.map((t) => TaskCard(
                  task: t,
                  onTap: () => onTap(t),
                  onComplete: () => onComplete(t),
                  onDelete: () => onDelete(t),
                )),
          ],
        ]),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String label;
  final Color? color;

  const _GroupHeader({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color ?? AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color ?? AppColors.textSecondary,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filtros activos ───────────────────────────────────────────────────────────

class _ActiveFiltersBar extends StatelessWidget {
  final Set<TaskPriority> filters;
  final VoidCallback onClear;

  const _ActiveFiltersBar({required this.filters, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.primaryLight,
      child: Row(
        children: [
          const Icon(Icons.filter_list_rounded,
              size: 14, color: AppColors.primaryDark),
          const SizedBox(width: 6),
          ...filters.map((p) => Container(
                margin: const EdgeInsets.only(right: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _priorityBg(p),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _priorityLabel(p),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: _priorityColor(p),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
          const Spacer(),
          GestureDetector(
            onTap: onClear,
            child: Text(
              'Limpiar',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(TaskPriority p) => p == TaskPriority.high
      ? AppColors.error
      : p == TaskPriority.medium
          ? AppColors.warning
          : AppColors.primary;

  Color _priorityBg(TaskPriority p) => p == TaskPriority.high
      ? AppColors.errorLight
      : p == TaskPriority.medium
          ? AppColors.warningLight
          : AppColors.primaryLight;

  String _priorityLabel(TaskPriority p) => p == TaskPriority.high
      ? 'Alta'
      : p == TaskPriority.medium
          ? 'Media'
          : 'Baja';
}

// ── Loading skeleton ──────────────────────────────────────────────────────────

class _TasksLoadingSkeleton extends StatelessWidget {
  const _TasksLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Mis tareas',
          style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ── Bottom sheet filtros ──────────────────────────────────────────────────────

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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
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
                  ? AppColors.error
                  : p == TaskPriority.medium
                      ? AppColors.warning
                      : AppColors.primary;
              final bg = p == TaskPriority.high
                  ? AppColors.errorLight
                  : p == TaskPriority.medium
                      ? AppColors.warningLight
                      : AppColors.primaryLight;
              final label = p == TaskPriority.high
                  ? 'Alta'
                  : p == TaskPriority.medium
                      ? 'Media'
                      : 'Baja';

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() =>
                      isSelected ? _selected.remove(p) : _selected.add(p)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? bg : AppColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : AppColors.border,
                        width: isSelected ? 2 : 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 13,
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
          const SizedBox(height: 20),
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
        ],
      ),
    );
  }
}