import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/notes_provider.dart';
import '../../../shared/widgets/empty_state.dart';

class NotesListScreen extends ConsumerStatefulWidget {
  const NotesListScreen({super.key});

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _selectedSubject;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allNotes = ref.watch(notesProvider);
    final subjects = allNotes
        .map((n) => n.subject)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();

    final filtered = allNotes.where((n) {
      final matchesQuery = _query.isEmpty ||
          n.title.toLowerCase().contains(_query.toLowerCase()) ||
          n.content.toLowerCase().contains(_query.toLowerCase());
      final matchesSubject =
          _selectedSubject == null || n.subject == _selectedSubject;
      return matchesQuery && matchesSubject;
    }).toList();

    final pinned = filtered.where((n) => n.isPinned).toList();
    final rest = filtered.where((n) => !n.isPinned).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Mis Notas',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            tooltip: 'Nueva nota',
            onPressed: () => context.push('/notes/create'),
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
          ),
          if (subjects.isNotEmpty)
            _SubjectFilter(
              subjects: subjects,
              selected: _selectedSubject,
              onSelected: (s) =>
                  setState(() => _selectedSubject = _selectedSubject == s ? null : s),
            ),
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(
                    icon: Icons.note_outlined,
                    title: 'Sin notas',
                    subtitle: 'Toca + para crear tu primera nota',
                  )
                : ListView(
                    padding: const EdgeInsets.only(bottom: 100),
                    children: [
                      if (pinned.isNotEmpty) ...[
                        _SectionHeader(title: '📌 Fijadas (${pinned.length})'),
                        ...pinned.map((n) => _NoteCard(
                              note: n,
                              onTap: () => context.push('/notes/${n.id}'),
                              onPin: () => ref
                                  .read(notesProvider.notifier)
                                  .togglePin(n.id),
                              onDelete: () => _confirmDelete(context, n.id),
                            )),
                      ],
                      if (rest.isNotEmpty) ...[
                        _SectionHeader(
                            title: pinned.isNotEmpty
                                ? 'Otras (${rest.length})'
                                : 'Todas (${rest.length})'),
                        ...rest.map((n) => _NoteCard(
                              note: n,
                              onTap: () => context.push('/notes/${n.id}'),
                              onPin: () => ref
                                  .read(notesProvider.notifier)
                                  .togglePin(n.id),
                              onDelete: () => _confirmDelete(context, n.id),
                            )),
                      ],
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/notes/create'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.black),
        label: Text('Nueva nota',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, color: Colors.black)),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Eliminar nota',
            style: GoogleFonts.inter(color: AppColors.textPrimary)),
        content: Text('¿Seguro que quieres eliminar esta nota?',
            style: GoogleFonts.inter(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar',
                  style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true && mounted) {
      ref.read(notesProvider.notifier).deleteNote(id);
    }
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: GoogleFonts.inter(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Buscar notas...',
          hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
          prefixIcon:
              const Icon(Icons.search_rounded, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }
}

class _SubjectFilter extends StatelessWidget {
  final List<String> subjects;
  final String? selected;
  final ValueChanged<String> onSelected;
  const _SubjectFilter(
      {required this.subjects,
      required this.selected,
      required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: subjects.map((s) {
          final isSelected = selected == s;
          return GestureDetector(
            onTap: () => onSelected(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface2,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                s,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color:
                      isSelected ? Colors.black : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onPin;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onPin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(note.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onPin(),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            icon: note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            label: note.isPinned ? 'Desfijar' : 'Fijar',
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12)),
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete_rounded,
            label: 'Eliminar',
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12)),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isPinned)
                    const Icon(Icons.push_pin_rounded,
                        size: 14, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                note.content,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (note.subject != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        note.subject!,
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    DateFormat('d MMM', 'es').format(note.createdAt),
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
