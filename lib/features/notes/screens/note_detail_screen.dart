import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/providers/notes_provider.dart';
import '../../../models/note.dart';

class NoteDetailScreen extends ConsumerStatefulWidget {
  final int? noteId;

  const NoteDetailScreen({super.key, this.noteId});

  @override
  ConsumerState<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends ConsumerState<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _subjectController;
  bool _isPinned = false;
  bool _isLoading = false;
  bool _isInitialized = false;

  bool get isEditing => widget.noteId != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _subjectController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _loadNote(NoteModel note) {
    if (_isInitialized) return;
    _titleController.text = note.title;
    _contentController.text = note.content ?? '';
    _subjectController.text = note.subject ?? '';
    _isPinned = note.isPinned;
    _isInitialized = true;
  }

  String _formatDate(DateTime date) {
    final months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
    return '${date.day} ${months[date.month - 1]}';
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título es obligatorio')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isEditing) {
        await ref.read(notesNotifierProvider.notifier).updateNote(
          widget.noteId!,
          title: title,
          content: _contentController.text.isEmpty ? null : _contentController.text,
          subject: _subjectController.text.isEmpty ? null : _subjectController.text,
          isPinned: _isPinned,
        );
      } else {
        await ref.read(notesNotifierProvider.notifier).create(
          title: title,
          content: _contentController.text.isEmpty ? null : _contentController.text,
          subject: _subjectController.text.isEmpty ? null : _subjectController.text,
          isPinned: _isPinned,
        );
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: const Text('¿Estás seguro de que quieres eliminar esta nota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(notesNotifierProvider.notifier).delete(widget.noteId!);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  NoteModel? get _currentNote {
    if (!isEditing) return null;
    final notes = ref.watch(notesNotifierProvider).value;
    if (notes == null) return null;
    return notes.where((n) => n.id == widget.noteId).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final note = _currentNote;
    if (note != null && note.userId.isNotEmpty && !_isInitialized) {
      _loadNote(note);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar nota' : 'Nueva nota',
          style: tt.headlineMedium,
        ),
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _isLoading ? null : _delete,
            ),
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Guardar',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.s4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              style: tt.headlineLarge,
              decoration: InputDecoration(
                hintText: 'Título',
                hintStyle: tt.headlineLarge?.copyWith(
                  color: AppColors.textDisabled,
                ),
                border: InputBorder.none,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const Divider(height: 24),
            TextField(
              controller: _subjectController,
              style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
              decoration: InputDecoration(
                hintText: 'Materia (opcional)',
                hintStyle: tt.bodyMedium?.copyWith(
                  color: AppColors.textDisabled,
                ),
                prefixIcon: const Icon(Icons.school_outlined, size: 20),
              ),
            ),
            SizedBox(height: AppSpacing.s4),
            TextField(
              controller: _contentController,
              style: tt.bodyLarge?.copyWith(height: 1.5),
              decoration: InputDecoration(
                hintText: 'Contenido',
                hintStyle: tt.bodyLarge?.copyWith(
                  color: AppColors.textDisabled,
                ),
                border: InputBorder.none,
              ),
              maxLines: null,
              minLines: 10,
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: AppSpacing.s4),
            if (note != null && note.id != null && note.userId.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.s1),
                  Text(
                    'Creada: ${_formatDate(note.createdAt)}',
                    style: tt.bodySmall,
                  ),
                  if (note.updateAt != null) ...[
                    SizedBox(width: AppSpacing.s4),
                    Icon(
                      Icons.update_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.s1),
                    Text(
                      'Actualizada: ${_formatDate(note.updateAt!)}',
                      style: tt.bodySmall,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4, vertical: AppSpacing.s3),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withAlpha(AppAlpha.a05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Text(
                'Fijar nota',
                style: tt.titleMedium,
              ),
              const Spacer(),
              Switch(
                value: _isPinned,
                onChanged: (value) => setState(() => _isPinned = value),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
