import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/courses_provider.dart';
import '../../../models/course.dart';
import '../../../shared/widgets/captus_pressable.dart';

class ActivityDetailStudentScreen extends ConsumerStatefulWidget {
  final String courseId;
  final String activityId;

  const ActivityDetailStudentScreen({
    super.key,
    required this.courseId,
    required this.activityId,
  });

  @override
  ConsumerState<ActivityDetailStudentScreen> createState() =>
      _ActivityDetailStudentScreenState();
}

class _ActivityDetailStudentScreenState
    extends ConsumerState<ActivityDetailStudentScreen> {
  final _commentController = TextEditingController();
  bool _fileSelected = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _formatCountdown(DateTime dueDate) {
    final diff = dueDate.difference(DateTime.now());
    if (diff.isNegative) return 'Vencida';
    if (diff.inDays > 0)
      return 'Vence en ${diff.inDays} día${diff.inDays == 1 ? '' : 's'}';
    if (diff.inHours > 0)
      return 'Vence en ${diff.inHours} hora${diff.inHours == 1 ? '' : 's'}';
    return 'Vence en ${diff.inMinutes} minuto${diff.inMinutes == 1 ? '' : 's'}';
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseByIdProvider(widget.courseId));

    return courseAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            tooltip: 'Volver',
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text('No se pudo cargar la actividad',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
        ),
      ),
      data: (course) {
        // Try to find the activity; use a placeholder if activities are empty
        final ActivityModel activity;
        if (course != null && course.activities.isNotEmpty) {
          try {
            activity = course.activities
                .firstWhere((a) => a.id == widget.activityId);
          } catch (_) {
            return _buildNotFound(context);
          }
        } else {
          activity = ActivityModel(
            id: widget.activityId,
            title: 'Actividad',
            dueDate: DateTime.now().add(const Duration(days: 3)),
            type: 'Tarea',
          );
        }
        return _buildBody(context, course, activity);
      },
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Scaffold(
      restorationId: 'activity_detail_student_screen',
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          tooltip: 'Volver',
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Text('Actividad no encontrada',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, CourseModel? course, ActivityModel activity) {
    final color =
        AppColors.courseColor(course?.colorIndex ?? 0);
    final dueDiff = activity.dueDate.difference(DateTime.now());
    final isOverdue = dueDiff.isNegative;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          tooltip: 'Volver',
          onPressed: () => context.pop(),
        ),
        title: Text(
          activity.type,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textSecondary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s4),
        children: [
          Text(
            activity.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? AppColors.error.withAlpha(AppAlpha.a15)
                      : dueDiff.inHours < 24
                          ? AppColors.warning.withAlpha(AppAlpha.a15)
                          : color.withAlpha(AppAlpha.a10),
                  borderRadius: BorderRadius.circular(AppRadius.r3),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: isOverdue
                          ? AppColors.error
                          : dueDiff.inHours < 24
                              ? AppColors.warning
                              : color,
                    ),
                    const SizedBox(width: AppSpacing.s1),
                    Text(
                      _formatCountdown(activity.dueDate),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 12,
                        color: isOverdue
                            ? AppColors.error
                            : dueDiff.inHours < 24
                                ? AppColors.warning
                                : color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s2),
              if (activity.requiresFile)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(AppRadius.r3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.attach_file,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: AppSpacing.s1),
                      Text(
                        'Requiere archivo',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (activity.description != null) ...[
            const SizedBox(height: AppSpacing.s5),
            Container(
              padding: const EdgeInsets.all(AppSpacing.s4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r6),
              ),
              child: Text(
                activity.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.s6),
          Text(
            'Mi entrega',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.s3),
          if (activity.isGraded) ...[
            _GradedView(activity: activity, color: color),
          ] else if (activity.isSubmitted) ...[
            _SubmittedView(),
          ] else ...[
            _UploadView(
              fileSelected: _fileSelected,
              commentController: _commentController,
              onFileTap: () => setState(() => _fileSelected = !_fileSelected),
              requiresFile: activity.requiresFile,
            ),
          ],
          const SizedBox(height: AppSpacing.s25),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        isGraded: activity.isGraded,
        isSubmitted: activity.isSubmitted,
        onSubmit: () {
          if (activity.isGraded || activity.isSubmitted) {
            // Actividad ya entregada/calificada → abrir IA
            context.push('/ai');
          } else {
            // Navegar a pantalla real de entrega
            context.push(
              '/student/assignments/${widget.activityId}/submit',
            );
          }
        },
      ),
    );
  }
}

class _GradedView extends StatelessWidget {
  final ActivityModel activity;
  final Color color;

  const _GradedView({required this.activity, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r7),
        border: Border.all(color: AppColors.primary.withAlpha(AppAlpha.a30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.s2),
              Text(
                'Calificada',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s5),
          if (activity.grade != null) ...[
            Text(
              activity.grade!.toStringAsFixed(1),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 56,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                height: 1,
              ),
            ),
            Text(
              '/ 5.0',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
          if (activity.feedback != null) ...[
            const SizedBox(height: AppSpacing.s4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s3),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(AppRadius.r4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Retroalimentación',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  Text(
                    activity.feedback!,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubmittedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.info.withAlpha(AppAlpha.a10),
        borderRadius: BorderRadius.circular(AppRadius.r6),
        border: Border.all(color: AppColors.info.withAlpha(AppAlpha.a30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_done, color: AppColors.info, size: 28),
          const SizedBox(width: AppSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entrega enviada',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.info),
                ),
                Text(
                  'En espera de calificación.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadView extends StatelessWidget {
  final bool fileSelected;
  final TextEditingController commentController;
  final VoidCallback onFileTap;
  final bool requiresFile;

  const _UploadView({
    required this.fileSelected,
    required this.commentController,
    required this.onFileTap,
    required this.requiresFile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (requiresFile) ...[
          CaptusPressable(
            onTap: onFileTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.s5),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r6),
                border: Border.all(
                  color: fileSelected ? AppColors.primary : AppColors.border,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    fileSelected
                        ? Icons.check_circle_outline
                        : Icons.cloud_upload_outlined,
                    size: 40,
                    color: fileSelected
                        ? AppColors.primary
                        : AppColors.textDisabled,
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    fileSelected
                        ? 'archivo_entrega.pdf'
                        : 'Toca para seleccionar archivo',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 13,
                      color: fileSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (!fileSelected)
                    Text(
                      'PDF, DOC, ZIP — máx. 50 MB',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textDisabled),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
        ],
        TextField(
          controller: commentController,
          maxLines: 4,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Comentario para el docente (opcional)...',
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool isGraded;
  final bool isSubmitted;
  final VoidCallback onSubmit;

  const _BottomBar({
    required this.isGraded,
    required this.isSubmitted,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final showAiButton = isGraded || isSubmitted;

    return Container(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.s4, AppSpacing.s3, AppSpacing.s4, MediaQuery.of(context).padding.bottom + AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: onSubmit,
          icon: Icon(
            showAiButton ? Icons.auto_awesome : Icons.upload,
            size: 18,
          ),
          label: Text(
            showAiButton ? 'Pedir ayuda al IA' : 'Subir entrega',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                showAiButton ? AppColors.surface2 : AppColors.primary,
            foregroundColor: showAiButton ? AppColors.primary : AppColors.textOnPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.r6),
              side: showAiButton
                  ? BorderSide(color: AppColors.primary.withAlpha(AppAlpha.a50))
                  : BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
