import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _solutionCtrl = TextEditingController();
  final _attachmentCtrl = TextEditingController();

  Map<String, dynamic>? _task;
  Map<String, dynamic>? _mySubmission;
  List<Map<String, dynamic>> _submissions = [];

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isTeacherOwner = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  @override
  void dispose() {
    _solutionCtrl.dispose();
    _attachmentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    final assignmentId = int.tryParse(widget.taskId);
    final user = Supabase.instance.client.auth.currentUser;

    if (assignmentId == null || user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final task = await Supabase.instance.client
          .from('course_assignments')
          .select()
          .eq('id', assignmentId)
          .maybeSingle();

      if (task == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      final isTeacherOwner =
          task['teacher_id']?.toString() == user.id;

      if (isTeacherOwner) {
        final submissionsResponse = await Supabase.instance.client
            .from('assignment_submissions')
            .select()
            .eq('assignment_id', assignmentId)
            .order('submitted_at', ascending: false);

        if (!mounted) return;
        setState(() {
          _task = task;
          _isTeacherOwner = true;
          _submissions = List<Map<String, dynamic>>.from(
              submissionsResponse as List);
          _isLoading = false;
        });
      } else {
        final submission = await Supabase.instance.client
            .from('assignment_submissions')
            .select()
            .eq('assignment_id', assignmentId)
            .eq('student_id', user.id)
            .maybeSingle();

        if (submission != null) {
          _solutionCtrl.text =
              submission['solution_text']?.toString() ?? '';
          _attachmentCtrl.text =
              submission['attachment_url']?.toString() ?? '';
        }

        if (!mounted) return;
        setState(() {
          _task = task;
          _mySubmission = submission;
          _isTeacherOwner = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar la tarea: $e')),
      );
    }
  }

  Future<void> _submitSolution() async {
    final assignmentId = int.tryParse(widget.taskId);
    final user = Supabase.instance.client.auth.currentUser;

    if (assignmentId == null || user == null) return;

    if (_solutionCtrl.text.trim().isEmpty &&
        _attachmentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Escribe tu solución o pega un enlace')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final existing = await Supabase.instance.client
          .from('assignment_submissions')
          .select('id')
          .eq('assignment_id', assignmentId)
          .eq('student_id', user.id)
          .maybeSingle();

      final data = {
        'assignment_id': assignmentId,
        'student_id': user.id,
        'solution_text': _solutionCtrl.text.trim(),
        'attachment_url': _attachmentCtrl.text.trim().isEmpty
            ? null
            : _attachmentCtrl.text.trim(),
        'submitted_at': DateTime.now().toIso8601String(),
      };

      if (existing == null) {
        await Supabase.instance.client
            .from('assignment_submissions')
            .insert(data);
      } else {
        await Supabase.instance.client
            .from('assignment_submissions')
            .update(data)
            .eq('id', existing['id']);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solución enviada correctamente')),
      );
      await _loadDetail();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar solución: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _gradeSubmission(
    Map<String, dynamic> submission,
    double grade,
    String feedback,
  ) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || !_isTeacherOwner) return;

    await Supabase.instance.client
        .from('assignment_submissions')
        .update({
          'grade': grade,
          'feedback':
              feedback.trim().isEmpty ? null : feedback.trim(),
          'graded_at': DateTime.now().toIso8601String(),
          'graded_by': user.id,
        })
        .eq('id', submission['id']);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calificación guardada')),
    );
    await _loadDetail();
  }

  void _openGradeDialog(Map<String, dynamic> submission) {
    final gradeCtrl = TextEditingController(
        text: submission['grade']?.toString() ?? '');
    final feedbackCtrl = TextEditingController(
        text: submission['feedback']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Calificar estudiante'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: gradeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Calificación',
                hintText: 'Ej: 4.5',
              ),
            ),
            const SizedBox(height: AppSpacing.s3),
            TextField(
              controller: feedbackCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Retroalimentación',
                hintText: 'Escribe comentarios para el estudiante',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final grade =
                  double.tryParse(gradeCtrl.text.trim());
              if (grade == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Ingresa una nota válida')),
                );
                return;
              }
              Navigator.pop(context);
              _gradeSubmission(
                  submission, grade, feedbackCtrl.text);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_task == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Detalle de tarea')),
        body: Center(
          child: ElevatedButton.icon(
            onPressed: () => context.go('/tasks'),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Volver a tareas'),
          ),
        ),
      );
    }

    final title = _task!['title']?.toString() ?? 'Sin título';
    final description = _task!['description']?.toString();
    final type = _task!['assignment_type']?.toString() ?? 'task';
    final dueDate = _task!['due_date']?.toString();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(type == 'evaluation' ? 'Evaluación' : 'Tarea'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s5),
        children: [
          Text(title, style: tt.displaySmall),
          const SizedBox(height: AppSpacing.s2),
          if (dueDate != null)
            Text('Fecha límite: $dueDate',
                style: tt.bodySmall!
                    .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.s5),
          Text(
            description == null || description.trim().isEmpty
                ? 'Sin descripción'
                : description,
            style: tt.bodyLarge!.copyWith(height: 1.5),
          ),
          const SizedBox(height: AppSpacing.s8),
          if (_isTeacherOwner) _teacherSubmissionsSection(tt),
          if (!_isTeacherOwner) _studentSubmissionSection(tt),
        ],
      ),
    );
  }

  Widget _studentSubmissionSection(TextTheme tt) {
    final grade = _mySubmission?['grade'];
    final feedback = _mySubmission?['feedback'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mi solución', style: tt.headlineMedium),
        const SizedBox(height: AppSpacing.s3),
        TextField(
          controller: _solutionCtrl,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Solución de la tarea',
            hintText: 'Escribe aquí tu solución...',
          ),
        ),
        const SizedBox(height: AppSpacing.s3),
        TextField(
          controller: _attachmentCtrl,
          decoration: const InputDecoration(
            labelText: 'Enlace de archivo o evidencia',
            hintText: 'Pega aquí un enlace si tienes archivo',
            prefixIcon: Icon(Icons.link_rounded, size: 20),
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submitSolution,
          icon: const Icon(Icons.upload_file),
          label: Text(
              _isSubmitting ? 'Enviando...' : 'Enviar solución'),
        ),
        const SizedBox(height: AppSpacing.s8),
        Text('Mi calificación', style: tt.headlineMedium),
        const SizedBox(height: AppSpacing.s3),
        Card(
          child: ListTile(
            title: Text(
                grade == null ? 'Aún no calificada' : 'Nota: $grade'),
            subtitle: Text(
              feedback == null || feedback.toString().trim().isEmpty
                  ? 'Sin retroalimentación todavía'
                  : feedback.toString(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _teacherSubmissionsSection(TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Entregas de estudiantes', style: tt.headlineMedium),
        const SizedBox(height: AppSpacing.s3),
        if (_submissions.isEmpty)
          Text('Aún no hay entregas para esta actividad',
              style: tt.bodyMedium!
                  .copyWith(color: AppColors.textSecondary))
        else
          ..._submissions.map((submission) {
            final studentId =
                submission['student_id']?.toString() ?? '';
            final solution =
                submission['solution_text']?.toString();
            final attachment =
                submission['attachment_url']?.toString();
            final grade = submission['grade']?.toString();

            return Card(
              margin:
                  const EdgeInsets.only(bottom: AppSpacing.s3),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estudiante: $studentId',
                        style: tt.bodySmall),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      solution == null || solution.trim().isEmpty
                          ? 'Sin texto de solución'
                          : solution,
                      style: tt.bodyMedium,
                    ),
                    if (attachment != null &&
                        attachment.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.s2),
                      Text('Archivo/enlace: $attachment',
                          style: tt.bodySmall),
                    ],
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                        grade == null
                            ? 'Sin calificar'
                            : 'Nota: $grade',
                        style: tt.labelLarge),
                    const SizedBox(height: AppSpacing.s2),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () =>
                            _openGradeDialog(submission),
                        child: const Text('Calificar'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
