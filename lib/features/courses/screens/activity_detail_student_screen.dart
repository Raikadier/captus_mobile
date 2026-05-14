import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/course.dart';

class ActivityDetailStudentScreen extends StatefulWidget {
  final String courseId;
  final String activityId;

  const ActivityDetailStudentScreen({
    super.key,
    required this.courseId,
    required this.activityId,
  });

  @override
  State<ActivityDetailStudentScreen> createState() =>
      _ActivityDetailStudentScreenState();
}

class _ActivityDetailStudentScreenState
    extends State<ActivityDetailStudentScreen> {
  final _commentController = TextEditingController();
  bool _fileSelected = false;

  late CourseModel _course;
  late ActivityModel _activity;

  @override
  void initState() {
    super.initState();
    _course = CourseModel.mockList.firstWhere(
      (c) => c.id == widget.courseId,
      orElse: () => CourseModel.mockList.first,
    );
    _activity = _course.activities.firstWhere(
      (a) => a.id == widget.activityId,
      orElse: () => _course.activities.isNotEmpty
          ? _course.activities.first
          : ActivityModel(
              id: widget.activityId,
              title: 'Actividad',
              dueDate: DateTime.now().add(const Duration(days: 3)),
              type: 'Tarea',
            ),
    );
  }

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
    final color = AppColors.courseColor(_course.colorIndex);
    final dueDiff = _activity.dueDate.difference(DateTime.now());
    final isOverdue = dueDiff.isNegative;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _activity.type,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _activity.title,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
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
                  borderRadius: BorderRadius.circular(8),
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
                    const SizedBox(width: 4),
                    Text(
                      _formatCountdown(_activity.dueDate),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
              const SizedBox(width: 8),
              if (_activity.requiresFile)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.attach_file,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Requiere archivo',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (_activity.description != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _activity.description!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Mi entrega',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (_activity.isGraded) ...[
            _GradedView(activity: _activity, color: color),
          ] else if (_activity.isSubmitted) ...[
            _SubmittedView(),
          ] else ...[
            _UploadView(
              fileSelected: _fileSelected,
              commentController: _commentController,
              onFileTap: () => setState(() => _fileSelected = !_fileSelected),
              requiresFile: _activity.requiresFile,
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        isGraded: _activity.isGraded,
        isSubmitted: _activity.isSubmitted,
        onSubmit: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _activity.isGraded || _activity.isSubmitted
                    ? 'Abriendo asistente IA...'
                    : 'Entrega enviada',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: AppColors.surface2,
            ),
          );
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(AppAlpha.a30)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Calificada',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (activity.grade != null) ...[
            Text(
              activity.grade!.toStringAsFixed(1),
              style: GoogleFonts.inter(
                fontSize: 56,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                height: 1,
              ),
            ),
            Text(
              '/ 5.0',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (activity.feedback != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Retroalimentación',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activity.feedback!,
                    style: GoogleFonts.inter(
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withAlpha(AppAlpha.a10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.info.withAlpha(AppAlpha.a30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_done, color: AppColors.info, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entrega enviada',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                  ),
                ),
                Text(
                  'En espera de calificación.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
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
          GestureDetector(
            onTap: onFileTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
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
                  const SizedBox(height: 8),
                  Text(
                    fileSelected
                        ? 'archivo_entrega.pdf'
                        : 'Toca para seleccionar archivo',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: fileSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (!fileSelected)
                    Text(
                      'PDF, DOC, ZIP — máx. 50 MB',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textDisabled,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: commentController,
          maxLines: 4,
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Comentario para el docente (opcional)...',
            hintStyle:
                GoogleFonts.inter(fontSize: 14, color: AppColors.textDisabled),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
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
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
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
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                showAiButton ? AppColors.surface2 : AppColors.primary,
            foregroundColor: showAiButton ? AppColors.primary : Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
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
