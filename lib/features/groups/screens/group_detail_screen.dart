import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/groups_provider.dart';
import '../../../models/group.dart';
import '../../../models/task.dart';
import '../../../shared/widgets/captus_pressable.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _checkedTasks = {};

  static const _activityFeed = [
    _ActivityEntry('Harold Flórez', 'creó la tarea', '"Revisar mockups"', '2h'),
    _ActivityEntry(
        'Isabella Manjarrez', 'completó', '"Diagrama de clases"', '5h'),
    _ActivityEntry('David Barceló', 'comentó en', '"Informe final"', 'Ayer'),
    _ActivityEntry(
        'Harold Flórez', 'adjuntó un archivo a', '"Informe final"', 'Ayer'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(myGroupsProvider);

    return groupsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            tooltip: 'Volver',
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text('No se pudo cargar el grupo',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ),
      ),
      data: (groups) {
        GroupModel? group;
        try {
          group = groups.firstWhere((g) => g.id == widget.groupId);
        } catch (_) {
          group = null;
        }

        if (group == null) {
          return Scaffold(
      restorationId: 'group_detail_screen',
            appBar: AppBar(
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                tooltip: 'Volver',
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
              child: Text('Grupo no encontrado',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            ),
          );
        }

        return _buildBody(context, group);
      },
    );
  }

  Widget _buildBody(BuildContext context, GroupModel group) {
    final tasks = <TaskModel>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          tooltip: 'Volver',
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (group.courseName != null)
              Text(
                group.courseName!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AppColors.textSecondary),
            tooltip: 'Configuración',
            onPressed: () =>
                context.push('/groups/${widget.groupId}/settings'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
          tabs: const [
            Tab(text: 'Tareas'),
            Tab(text: 'Miembros'),
            Tab(text: 'Actividad'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TasksTab(
            tasks: tasks,
            checkedTasks: _checkedTasks,
            onToggle: (id) => setState(() {
              if (_checkedTasks.contains(id)) {
                _checkedTasks.remove(id);
              } else {
                _checkedTasks.add(id);
              }
            }),
          ),
          _MembersTab(members: group.members),
          const _ActivityTab(feed: _activityFeed),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          if (_tabController.index != 0) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => context.push('/tasks/create'),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'Nueva tarea',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        },
      ),
    );
  }
}

class _TasksTab extends StatelessWidget {
  final List<TaskModel> tasks;
  final Set<String> checkedTasks;
  final ValueChanged<String> onToggle;

  const _TasksTab({
    required this.tasks,
    required this.checkedTasks,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Text(
          'Sin tareas en este grupo.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.s4),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s2 + 2),
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isDone = checkedTasks.contains(task.id.toString()) ||
            task.status == TaskStatus.completed;
        return CaptusPressable(
          onTap: () => onToggle(task.id.toString()),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r6),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? AppColors.primary
                        : AppColors.surface,
                    border: Border.all(
                      color: isDone
                          ? AppColors.primary
                          : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: isDone
                      ? const Icon(Icons.check,
                          size: 13, color: AppColors.textPrimary)
                      : null,
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isDone
                              ? AppColors.textDisabled
                              : AppColors.textPrimary,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (task.dueDate != null) ...[
                        const SizedBox(height: AppSpacing.s1),
                        Text(
                          _formatDue(task.dueDate!),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: task.isOverdue
                                ? AppColors.error
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _PriorityDot(priority: task.priority),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDue(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.isNegative) return 'Vencida';
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Mañana';
    return 'En ${diff.inDays} días';
  }
}

class _PriorityDot extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityDot({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case TaskPriority.high:
        color = AppColors.error;
      case TaskPriority.medium:
        color = AppColors.warning;
      case TaskPriority.low:
        color = AppColors.primary;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _MembersTab extends StatelessWidget {
  final List<GroupMember> members;

  const _MembersTab({required this.members});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.s4),
      itemCount: members.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.s2 + 2),
      itemBuilder: (context, index) {
        final member = members[index];
        final contribution = 0.4 + (index * 0.15).clamp(0.0, 0.6);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r6),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    AppColors.courseColor(index),
                child: Text(
                  member.name[0],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          member.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (member.isAdmin) ...[
                          const SizedBox(width: AppSpacing.s1),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primary.withAlpha(AppAlpha.a10),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r2),
                            ),
                            child: Text(
                              'Admin',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s1),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppRadius.r1),
                            child: LinearProgressIndicator(
                              value: contribution,
                              backgroundColor:
                                  AppColors.surface2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                AppColors.courseColor(index),
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s2),
                        Text(
                          '${(contribution * 100).toInt()}%',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityTab extends StatelessWidget {
  final List<_ActivityEntry> feed;

  const _ActivityTab({required this.feed});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.s4),
      itemCount: feed.length,
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(left: 52),
        child: Divider(color: AppColors.divider, height: 1),
      ),
      itemBuilder: (context, index) {
        final entry = feed[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    AppColors.courseColor(index),
                child: Text(
                  entry.actor[0],
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s3),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    children: [
                      TextSpan(
                        text: entry.actor,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: ' ${entry.action} '),
                      TextSpan(
                        text: entry.target,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              Text(
                entry.time,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textDisabled),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityEntry {
  final String actor;
  final String action;
  final String target;
  final String time;

  const _ActivityEntry(this.actor, this.action, this.target, this.time);
}
