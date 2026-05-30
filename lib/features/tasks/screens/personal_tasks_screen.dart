import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/tasks_provider.dart';
import '../../../core/providers/categories_provider.dart';
import '../../../shared/widgets/captus_fab.dart';
import '../../../shared/widgets/captus_pressable.dart';
import '../../../shared/widgets/task_card.dart';

class PersonalTasksScreen extends ConsumerStatefulWidget {
  const PersonalTasksScreen({super.key});

  @override
  ConsumerState<PersonalTasksScreen> createState() =>
      _PersonalTasksScreenState();
}

class _PersonalTasksScreenState extends ConsumerState<PersonalTasksScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    ref.read(taskFiltersProvider.notifier).clearAll();
  }

  bool get _hasActiveFilters {
    final filters = ref.read(taskFiltersProvider);
    return filters.searchQuery != '' ||
        filters.priorityFilter != null ||
        filters.categoryFilter != null ||
        filters.dateFilter != null;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final tasksAsync = ref.watch(filteredTasksProvider);
    final categoriesAsync = ref.watch(categoriesNotifierProvider);
    final filters = ref.watch(taskFiltersProvider);
    final priorityFilter = filters.priorityFilter;
    final categoryFilter = filters.categoryFilter;
    final dateFilter = filters.dateFilter;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tareas personales'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Gestionar categorías',
            onPressed: () => context.push('/tasks/categories'),
          ),
          const SizedBox(width: AppSpacing.s2),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Column(
              children: [
                // ── Search bar ────────────────────────────────────────────
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      ref
                          .read(taskFiltersProvider.notifier)
                          .setSearchQuery(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar tareas...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(taskFiltersProvider.notifier)
                                    .setSearchQuery('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s4, vertical: AppSpacing.s3),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s3),
                // ── Filters row ───────────────────────────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterDropdown(
                        value: priorityFilter,
                        hint: 'Prioridad',
                        items: const [
                          {'value': 1, 'label': 'Alta'},
                          {'value': 2, 'label': 'Media'},
                          {'value': 3, 'label': 'Baja'},
                        ],
                        onChanged: (val) {
                          ref
                              .read(taskFiltersProvider.notifier)
                              .setPriorityFilter(val);
                        },
                      ),
                      const SizedBox(width: AppSpacing.s2),
                      categoriesAsync.when(
                        data: (categories) => _FilterDropdown(
                          value: categoryFilter,
                          hint: 'Categoría',
                          items: categories
                              .map((c) =>
                                  {'value': c.id, 'label': c.name})
                              .toList(),
                          onChanged: (val) {
                            ref
                                .read(taskFiltersProvider.notifier)
                                .setCategoryFilter(val);
                          },
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(width: AppSpacing.s2),
                      _DateFilterChip(
                        selectedDate: dateFilter,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: dateFilter ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            ref
                                .read(taskFiltersProvider.notifier)
                                .setDateFilter(date);
                          }
                        },
                        onClear: () {
                          ref
                              .read(taskFiltersProvider.notifier)
                              .setDateFilter(null);
                        },
                      ),
                      if (_hasActiveFilters) ...[
                        const SizedBox(width: AppSpacing.s2),
                        CaptusPressable(
                          onTap: _clearFilters,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s3,
                                vertical: AppSpacing.s2),
                            decoration: BoxDecoration(
                              color: AppColors.error.withAlpha(AppAlpha.a10),
                              borderRadius: BorderRadius.circular(AppRadius.r3),
                              border: Border.all(
                                  color: AppColors.error.withAlpha(AppAlpha.a30)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.clear_rounded,
                                    size: 16, color: AppColors.error),
                                const SizedBox(width: AppSpacing.s1),
                                Text(
                                  'Limpiar',
                                  style: tt.labelLarge!
                                      .copyWith(color: AppColors.error),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: tasksAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: AppSpacing.s4),
                    Text('Error al cargar tareas',
                        style: tt.headlineSmall!
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppSpacing.s4),
                    ElevatedButton(
                      onPressed: () =>
                          ref.refresh(tasksNotifierProvider),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.assignment_outlined,
                            size: 64, color: AppColors.textDisabled),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          _hasActiveFilters
                              ? 'No hay tareas que coincidan'
                              : 'No hay tareas personales',
                          style: tt.headlineMedium!
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          _hasActiveFilters
                              ? 'Intenta con otros filtros'
                              : 'Crea tu primera tarea',
                          style: tt.bodyMedium!
                              .copyWith(color: AppColors.textDisabled),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s4),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskCard(
                      task: task,
                      onTap: () =>
                          context.push('/tasks/personal/${task.id}'),
                      onComplete: () => _completeTask(task.id!),
                      onDelete: () =>
                          _deleteTask(task.id!, task.title),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: CaptusFab(
        onPressed: () => context.push('/tasks/personal/create'),
        tooltip: 'Nueva tarea personal',
      ),
    );
  }

  Future<void> _completeTask(int taskId) async {
    try {
      await ref
          .read(tasksNotifierProvider.notifier)
          .completeWithSubtasks(taskId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.check_circle, color: AppColors.textOnPrimary),
              SizedBox(width: AppSpacing.s2),
              Text('Tarea completada'),
            ]),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _deleteTask(int taskId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Estás seguro de eliminar "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(tasksNotifierProvider.notifier).delete(taskId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(children: [
                Icon(Icons.delete, color: AppColors.textOnPrimary),
                SizedBox(width: AppSpacing.s2),
                Text('Tarea eliminada'),
              ]),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error: $e'),
                backgroundColor: AppColors.error),
          );
        }
      }
    }
  }
}

// ── Filter dropdown ───────────────────────────────────────────────────────────

class _FilterDropdown extends StatelessWidget {
  final int? value;
  final String hint;
  final List<Map<String, dynamic>> items;
  final ValueChanged<int?> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isActive = value != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s3),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryLight : AppColors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.r3),
        border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: value,
          dropdownColor: AppColors.surface,
          hint: Text(hint,
              style: tt.bodySmall!
                  .copyWith(color: AppColors.textSecondary)),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 20, color: AppColors.textSecondary),
          isDense: true,
          style: tt.bodySmall!.copyWith(color: AppColors.textPrimary),
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Text('Todas',
                  style: tt.bodySmall!
                      .copyWith(color: AppColors.textSecondary)),
            ),
            ...items.map((item) => DropdownMenuItem<int?>(
                  value: item['value'] as int,
                  child: Text(item['label'] as String),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ── Date filter chip ──────────────────────────────────────────────────────────

class _DateFilterChip extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateFilterChip({
    required this.selectedDate,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isActive = selectedDate != null;

    return CaptusPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s3, vertical: AppSpacing.s2),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryLight : AppColors.surface2,
          borderRadius: BorderRadius.circular(AppRadius.r3),
          border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive
                  ? Icons.calendar_today
                  : Icons.calendar_today_outlined,
              size: 14,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.s1),
            Text(
              isActive
                  ? DateFormat('d MMM', 'es').format(selectedDate!)
                  : 'Fecha',
              style: tt.bodySmall!.copyWith(
                color: isActive
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: AppSpacing.s1),
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.close,
                    size: 16, color: AppColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
