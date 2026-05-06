import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/assignments_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../models/submission.dart';

class StudentSubmissionCreateScreen extends ConsumerStatefulWidget {
  final String assignmentId;
  const StudentSubmissionCreateScreen({super.key, required this.assignmentId});

  @override
  ConsumerState<StudentSubmissionCreateScreen> createState() =>
      _StudentSubmissionCreateScreenState();
}

class _StudentSubmissionCreateScreenState
    extends ConsumerState<StudentSubmissionCreateScreen> {
  final _contentController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_contentController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('No autenticado');

      final submission = SubmissionModel(
        id: '',
        assignmentId: widget.assignmentId,
        studentId: user.id,
        content: _contentController.text.trim(),
        fileUrl: '', // Se podría integrar file picker en el futuro
        submittedAt: DateTime.now(),
        status: 'submitted',
      );

      final notifier = ref.read(studentAssignmentsProvider.notifier);
      await notifier.createSubmission(submission);

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Entregado con éxito')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Entregar Tarea',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Escribe tu respuesta o contenido adjunto:',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'Tu respuesta aquí...',
                  hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text('Enviar Entrega',
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
