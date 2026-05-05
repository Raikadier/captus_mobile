import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/group.dart';
import '../../../models/task.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late GroupModel _group;
  late List<TaskModel> _tasks;
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
    _group = GroupModel.mockList.firstWhere(
      (g) => g.id == widget.groupId,
      orElse: () => GroupModel.mockList.first,
    );
    _tasks =
        TaskModel.mockList.where((t) => t.groupId == widget.groupId).toList();
    if (_tasks.isEmpty) _tasks = TaskModel.mockList.take(3).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _group.name,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (_group.courseName != null)
              Text(
                _group.courseName!,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AppColors.textSecondary),
            onPressed: () => context.push('/groups/${widget.groupId}/settings'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          labelStyle:
              GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 13),
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
            tasks: _tasks,
            checkedTasks: _checkedTasks,
            onToggle: (id) => setState(() {
              if (_checkedTasks.contains(id)) {
                _checkedTasks.remove(id);
              } else {
                _checkedTasks.add(id);
              }
            }),
          ),
          _MembersTab(members: _group.members),
          const _ActivityTab(feed: _activityFeed),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          if (_tabController.index != 0) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () {},
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.black),
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
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isDone = checkedTasks.contains(task.id) ||
            task.status == TaskStatus.completed;
        return GestureDetector(
          onTap: () => onToggle(task.id),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isDone ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: isDone
                      ? const Icon(Icons.check, size: 13, color: Colors.black)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDone
                              ? AppColors.textDisabled
                              : AppColors.textPrimary,
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (task.dueDate != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          _formatDue(task.dueDate!),
                          style: GoogleFonts.inter(
                            fontSize: 11,
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
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final member = members[index];
        final contribution = 0.4 + (index * 0.15).clamp(0.0, 0.6);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.courseColor(index),
                child: Text(
                  member.name[0],
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          member.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (member.isAdmin) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Admin',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: contribution,
                              backgroundColor: AppColors.surface2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.courseColor(index),
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(contribution * 100).toInt()}%',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
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
      padding: const EdgeInsets.all(16),
      itemCount: feed.length,
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(left: 52),
        child: Divider(color: AppColors.divider, height: 1),
      ),
      itemBuilder: (context, index) {
        final entry = feed[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.courseColor(index),
                child: Text(
                  entry.actor[0],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary),
                    children: [
                      TextSpan(
                        text: entry.actor,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: ' ${entry.action} '),
                      TextSpan(
                        text: entry.target,
                        style: const TextStyle(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                entry.time,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textDisabled,
                ),
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
