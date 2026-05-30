import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../shared/widgets/cactus_refresh.dart';
import '../../../shared/widgets/captus_dialog.dart';
import '../../../shared/widgets/captus_fab.dart';
import '../../../shared/widgets/loading_shimmer.dart';

class TasksListScreen extends ConsumerStatefulWidget {
  const TasksListScreen({super.key});

  @override
  ConsumerState<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends ConsumerState<TasksListScreen> {
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final response = await Supabase.instance.client
          .from('course_assignments')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) return;
      setState(() {
        _tasks = (response as List<dynamic>).cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      debugPrint('ERROR fetching tasks: $e');
    }
  }

  Future<void> _completeTask(String id) async {
    HapticFeedback.lightImpact();
    setState(() => _tasks.removeWhere((t) => t['id']?.toString() == id));
    try {
      await Supabase.instance.client
          .from('course_assignments')
          .update({'completed': true})
          .eq('id', id);
    } catch (e) {
      debugPrint('ERROR completing task: $e');
      if (mounted) await _fetchTasks();
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✓ Tarea completada'),
        backgroundColor: AppColors.primaryDark,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Deshacer',
          textColor: AppColors.textOnPrimary,
          onPressed: _fetchTasks,
        ),
      ),
    );
  }

  Future<void> _deleteTask(String id, String title) async {
    final confirmed = await CaptusDialog.confirm(
      context: context,
      title: 'Eliminar tarea',
      message: '¿Eliminar "$title"? Esta acción no se puede deshacer.',
      confirmLabel: 'Eliminar',
      isDangerous: true,
    );

    if (!confirmed) {
      await _fetchTasks();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _tasks.removeWhere((t) => t['id']?.toString() == id));
    try {
      await Supabase.instance.client
          .from('course_assignments')
          .delete()
          .eq('id', id);
    } catch (_) {
      if (mounted) await _fetchTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis tareas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_rounded),
            tooltip: 'Gestionar categorías',
            onPressed: () => context.push('/tasks/categories'),
          ),
          const SizedBox(width: AppSpacing.s2),
        ],
      ),
      body: Column(
        children: [
          // ── Personal tasks shortcut ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.s4, AppSpacing.s3, AppSpacing.s4, 0),
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.r5),
              child: InkWell(
                onTap: () => context.push('/tasks/personal'),
                borderRadius: BorderRadius.circular(AppRadius.r5),
                splashColor: AppColors.textOnPrimary.withAlpha(AppAlpha.a10),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s4),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.textOnPrimary.withAlpha(AppAlpha.a20),
                          borderRadius: BorderRadius.circular(AppRadius.r4),
                        ),
                        child: const Icon(
                          Icons.assignment_rounded,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tareas personales',
                              style: tt.headlineSmall!.copyWith(
                                  color: AppColors.textOnPrimary),
                            ),
                            const SizedBox(height: AppSpacing.s1),
                            Text(
                              'Gestiona tus tareas propias',
                              style: tt.bodySmall!.copyWith(
                                  color: AppColors.textOnPrimary
                                      .withAlpha(AppAlpha.a70)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.textOnPrimary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ── Task list ────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.s4),
                    child: TaskListShimmer(count: 5),
                  )
                : _tasks.isEmpty
                    ? Center(
                        child: Text('No hay tareas',
                            style: tt.bodyMedium!.copyWith(
                                color: AppColors.textSecondary)))
                    : CactusRefresh(
                        onRefresh: _fetchTasks,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                              AppSpacing.s4, AppSpacing.s4,
                              AppSpacing.s4, 100),
                          itemCount: _tasks.length,
                          itemBuilder: (context, index) {
                            final task = _tasks[index];
                            final id = task['id']?.toString() ?? '';
                            final title =
                                task['title']?.toString() ?? 'Sin título';
                            final description =
                                task['description']?.toString() ??
                                    'Sin descripción';
                            final type =
                                task['assignment_type']?.toString() ??
                                    'task';

                            return _SwipeableTaskCard(
                              key: ValueKey(id),
                              id: id,
                              title: title,
                              description: description,
                              type: type,
                              onTap: id.isEmpty
                                  ? null
                                  : () => context.push('/tasks/$id'),
                              onComplete: () => _completeTask(id),
                              onDelete: () => _deleteTask(id, title),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: CaptusFab(
        onPressed: () => context.push('/tasks/create'),
        tooltip: 'Nueva tarea',
      ),
    );
  }
}

// ── Swipeable task card ───────────────────────────────────────────────────────

class _SwipeableTaskCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String type;
  final VoidCallback? onTap;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const _SwipeableTaskCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.onComplete,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s3),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(AppRadius.r6),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.s5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: AppColors.textOnPrimary, size: 22),
            const SizedBox(width: AppSpacing.s2),
            Text('Completar',
                style: tt.headlineSmall!
                    .copyWith(color: AppColors.textOnPrimary)),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s3),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppRadius.r6),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.s5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Eliminar',
                style: tt.headlineSmall!
                    .copyWith(color: AppColors.textOnPrimary)),
            const SizedBox(width: AppSpacing.s2),
            const Icon(Icons.delete_outline_rounded,
                color: AppColors.textOnPrimary, size: 22),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onComplete();
        } else {
          onDelete();
        }
        return false;
      },
      child: _TaskCardContent(
        title: title,
        description: description,
        type: type,
        onTap: onTap,
      ),
    );
  }
}

// ── Task card content ─────────────────────────────────────────────────────────

class _TaskCardContent extends StatelessWidget {
  final String title;
  final String description;
  final String type;
  final VoidCallback? onTap;

  const _TaskCardContent({
    required this.title,
    required this.description,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isEvaluation = type == 'evaluation';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r6),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.r6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.r6),
          splashColor: AppColors.primary.withAlpha(AppAlpha.a10),
          highlightColor: AppColors.primary.withAlpha(AppAlpha.a05),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s4,
                vertical: AppSpacing.s3 + 2),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isEvaluation
                        ? AppColors.warning
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.r1),
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: tt.headlineSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.s1),
                      Text(
                        description,
                        style: tt.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s2),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s2, vertical: AppSpacing.s1),
                  decoration: BoxDecoration(
                    color: isEvaluation
                        ? AppColors.warningLight
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(AppRadius.r3),
                  ),
                  child: Text(
                    isEvaluation ? 'Evaluación' : 'Tarea',
                    style: tt.labelSmall!.copyWith(
                      color: isEvaluation
                          ? AppColors.warning
                          : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
