import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/notes_provider.dart';

class NoteCreateScreen extends ConsumerStatefulWidget {
  final String? noteId;
  const NoteCreateScreen({super.key, this.noteId});

  @override
  ConsumerState<NoteCreateScreen> createState() => _NoteCreateScreenState();
}

class _NoteCreateScreenState extends ConsumerState<NoteCreateScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  bool _isPinned = false;
  bool _isLoading = false;
  Note? _existing;

  static const _subjects = [
    'Estructuras de Datos',
    'Cálculo II',
    'Ingeniería de Software I',
    'Sistemas Operativos',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.noteId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadNote());
    }
  }

  void _loadNote() {
    final notes = ref.read(notesProvider);
    final found = notes.where((n) => n.id == widget.noteId).firstOrNull;
    if (found != null) {
      setState(() {
        _existing = found;
        _titleCtrl.text = found.title;
        _contentCtrl.text = found.content;
        _subjectCtrl.text = found.subject ?? '';
        _isPinned = found.isPinned;
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _subjectCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título no puede estar vacío')),
      );
      return;
    }
    setState(() => _isLoading = true);

    final notifier = ref.read(notesProvider.notifier);
    final now = DateTime.now();

    if (_existing != null) {
      final updated = _existing!.copyWith(
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        subject: _subjectCtrl.text.trim().isEmpty
            ? null
            : _subjectCtrl.text.trim(),
        isPinned: _isPinned,
        updatedAt: now,
      );
      await notifier.updateNote(updated);
    } else {
      final note = Note(
        id: 'n${now.millisecondsSinceEpoch}',
        title: _titleCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
        subject:
            _subjectCtrl.text.trim().isEmpty ? null : _subjectCtrl.text.trim(),
        isPinned: _isPinned,
        createdAt: now,
      );
      await notifier.addNote(note);
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.noteId != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          isEditing ? 'Editar nota' : 'Nueva nota',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              color: _isPinned ? AppColors.primary : AppColors.textSecondary,
            ),
            onPressed: () => setState(() => _isPinned = !_isPinned),
          ),
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: Text(
              'Guardar',
              style: GoogleFonts.inter(
                  color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Label('Título *'),
            const SizedBox(height: 6),
            TextField(
              controller: _titleCtrl,
              style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              decoration: _inputDecoration('Título de la nota'),
              maxLength: 80,
            ),
            const SizedBox(height: 16),
            _Label('Materia'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _subjects.map((s) {
                final isSelected = _subjectCtrl.text == s;
                return GestureDetector(
                  onTap: () => setState(() =>
                      _subjectCtrl.text = isSelected ? '' : s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : AppColors.surface2,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      s,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.black
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _Label('Contenido'),
            const SizedBox(height: 6),
            TextField(
              controller: _contentCtrl,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textPrimary, height: 1.6),
              decoration: _inputDecoration(
                  'Escribe tu nota aquí...',
                  minLines: 10),
              maxLines: null,
              minLines: 10,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text('Guardar nota',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {int? minLines}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.border, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.4),
    );
  }
}
