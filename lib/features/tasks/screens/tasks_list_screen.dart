import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_animations.dart';
import '../../../shared/widgets/captus_dialog.dart';
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
        _tasks = (response as List<dynamic>)
            .cast<Map<String, dynamic>>();
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
      // Re-fetch to restore the dismissed item
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
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Personal tasks shortcut ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => context.push('/tasks/personal'),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.textOnPrimary
                              .withAlpha(AppAlpha.a20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.assignment_rounded,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tareas personales',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Gestiona tus tareas propias',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textOnPrimary
                                    .withAlpha(AppAlpha.a70),
                              ),
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
          // ── Task list ─────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: TaskListShimmer(count: 5),
                  )
                : _tasks.isEmpty
                    ? Center(
                        child: Text(
                          'No hay tareas de cursos',
                          style: GoogleFonts.inter(
                              color: AppColors.textSecondary),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchTasks,
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
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
                                task['assignment_type']?.toString() ?? 'task';

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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tasks/create'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

// ─── Swipeable task card ──────────────────────────────────────────────────────

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
    this.onTap,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismissible_$id'),
      // ── Complete: swipe left ──────────────────────────────────────────────
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded,
                color: AppColors.textOnPrimary, size: 28),
            SizedBox(height: 4),
            Text('Completar',
                style: TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      // ── Delete: swipe right ───────────────────────────────────────────────
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_rounded,
                color: AppColors.textOnPrimary, size: 28),
            SizedBox(height: 4),
            Text('Eliminar',
                style: TextStyle(
                    color: AppColors.textOnPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe left = complete (no confirmation needed)
          return true;
        }
        // Swipe right = delete (needs confirmation)
        return CaptusDialog.confirm(
          context: context,
          title: 'Eliminar tarea',
          message: '¿Eliminar "$title"? Esta acción no se puede deshacer.',
          confirmLabel: 'Eliminar',
          isDangerous: true,
        );
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onComplete();
        } else {
          HapticFeedback.mediumImpact();
          onDelete();
        }
      },
      resizeDuration: AppDurations.fast,
      movementDuration: AppDurations.standard,
      child: _TaskCardContent(
        title: title,
        description: description,
        type: type,
        onTap: onTap,
      ),
    );
  }
}

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
    final isEvaluation = type == 'evaluation';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.primary.withAlpha(AppAlpha.a10),
          highlightColor: AppColors.primary.withAlpha(AppAlpha.a05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Type indicator
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isEvaluation
                        ? AppColors.warning
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isEvaluation
                        ? AppColors.warningLight
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isEvaluation ? 'Evaluación' : 'Tarea',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isEvaluation
                          ? AppColors.warning
                          : AppColors.primary,
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
