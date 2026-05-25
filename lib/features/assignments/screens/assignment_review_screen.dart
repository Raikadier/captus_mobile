import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/assignments_provider.dart';

class AssignmentReviewScreen extends ConsumerStatefulWidget {
  final String assignmentId;
  const AssignmentReviewScreen({super.key, required this.assignmentId});

  @override
  ConsumerState<AssignmentReviewScreen> createState() =>
      _AssignmentReviewScreenState();
}

class _AssignmentReviewScreenState
    extends ConsumerState<AssignmentReviewScreen> {
  Future<void> _showGradeDialog(BuildContext context, String submissionId, double? currentGrade, String? currentFeedback) async {
    double grade = currentGrade ?? 0.0;
    String feedback = currentFeedback ?? '';
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Calificar Entrega',
              style: GoogleFonts.inter(color: AppColors.textPrimary)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: grade > 0 ? grade.toString() : '',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Nota (1.0 - 5.0)'),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Ingresa una nota';
                    final parsed = double.tryParse(val);
                    if (parsed == null) return 'Número inválido';
                    if (parsed < 1.0 || parsed > 5.0) return 'La nota debe estar entre 1.0 y 5.0';
                    return null;
                  },
                  onSaved: (val) => grade = double.tryParse(val!) ?? 0.0,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: feedback,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Feedback'),
                  onSaved: (val) => feedback = val ?? '',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                formKey.currentState!.save();
                Navigator.pop(ctx);
                try {
                  await ref.read(teacherAssignmentsProvider.notifier).gradeSubmission(
                      widget.assignmentId, submissionId, grade, feedback);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Calificación guardada')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al guardar: $e')),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _copyFileUrl(String urlString) {
    // using dart:core functionality directly or could use Clipboard from services.
    // Instead of importing services, we just show a snackbar showing the url
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('URL del archivo adjunto:\n$urlString'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final submissionsAsync =
        ref.watch(submissionsProvider(widget.assignmentId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Revisar Entregas',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: submissionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err', style: GoogleFonts.inter(color: Colors.red))),
        data: (submissions) {
          if (submissions.isEmpty) {
            return Center(
                child: Text('Aún no hay entregas para esta asignación.',
                style: GoogleFonts.inter(color: AppColors.textSecondary)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final sub = submissions[index];
              return Card(
                color: AppColors.surface,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              sub.groupId != null && sub.groupId!.isNotEmpty 
                                  ? 'Grupo: ${sub.groupId}' 
                                  : 'Estudiante: ${sub.studentId}',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: AppColors.textPrimary)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: sub.graded ? AppColors.primary.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              sub.graded ? 'Calificado' : 'Pendiente',
                              style: GoogleFonts.inter(
                                color: sub.graded ? AppColors.primary : Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Entregado el: ${sub.submittedAt.toString().substring(0, 16)}',
                          style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 12),
                      
                      if (sub.content != null && sub.content!.isNotEmpty) ...[
                        Text('Respuesta:', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13)),
                        const SizedBox(height: 4),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(sub.content!, style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 13)),
                        ),
                        const SizedBox(height: 12),
                      ],
                      
                      if (sub.fileUrl != null && sub.fileUrl!.isNotEmpty) ...[
                        OutlinedButton.icon(
                          onPressed: () => _copyFileUrl(sub.fileUrl!),
                          icon: const Icon(Icons.attach_file, size: 18),
                          label: const Text('Ver url del archivo adjunto'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ] else ...[
                        Text('Sin archivo adjunto', style: GoogleFonts.inter(color: AppColors.textSecondary, fontStyle: FontStyle.italic, fontSize: 13)),
                      ],
                      
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nota actual: ${sub.grade != null ? sub.grade.toString() : "Sin nota"}',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showGradeDialog(context, sub.id, sub.grade, sub.feedback),
                            icon: const Icon(Icons.grading, size: 18),
                            label: const Text('Calificar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
