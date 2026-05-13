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
  void _showGradeDialog(BuildContext context, String submissionId) {
    double grade = 0.0;
    String feedback = '';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Calificar Entrega',
              style: GoogleFonts.inter(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Nota'),
                onChanged: (val) => grade = double.tryParse(val) ?? 0.0,
              ),
              const SizedBox(height: 12),
              TextField(
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Feedback'),
                onChanged: (val) => feedback = val,
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                ref.read(teacherAssignmentsProvider.notifier).gradeSubmission(
                    widget.assignmentId, submissionId, grade, feedback);
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
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
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (submissions) {
          if (submissions.isEmpty) {
            return const Center(
                child: Text('Aún no hay entregas para esta asignación.'));
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
                child: ListTile(
                  title: Text('Estudiante: ${sub.studentId}',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  subtitle: Text(
                      'Estado: ${sub.status}\nNota: ${sub.grade ?? "Sin nota"}',
                      style: GoogleFonts.inter(color: AppColors.textSecondary)),
                  trailing: const Icon(Icons.grading, color: AppColors.primary),
                  onTap: () => _showGradeDialog(context, sub.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
