import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final String? subject;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    this.subject,
    this.isPinned = false,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'subject': subject,
        'isPinned': isPinned,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        content: json['content']?.toString() ?? '',
        subject: json['subject']?.toString(),
        isPinned: json['isPinned'] as bool? ?? false,
        createdAt:
            DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'].toString())
            : null,
      );

  Note copyWith({
    String? title,
    String? content,
    String? subject,
    bool? isPinned,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      subject: subject ?? this.subject,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class NotesNotifier extends Notifier<List<Note>> {
  @override
  List<Note> build() {
    return LocalStorageService.notes.map((n) => Note.fromJson(n)).toList();
  }

  Future<void> addNote(Note note) async {
    await LocalStorageService.addNote(note.toJson());
    state = [note, ...state];
  }

  Future<void> updateNote(Note note) async {
    await LocalStorageService.updateNote(note.id, note.toJson());
    state = state.map((n) => n.id == note.id ? note : n).toList();
  }

  Future<void> deleteNote(String id) async {
    await LocalStorageService.deleteNote(id);
    state = state.where((n) => n.id != id).toList();
  }

  Future<void> togglePin(String id) async {
    final note = state.firstWhere((n) => n.id == id);
    final updated = note.copyWith(
      isPinned: !note.isPinned,
      updatedAt: DateTime.now(),
    );
    await updateNote(updated);
  }
}

final notesProvider = NotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);

final pinnedNotesProvider = Provider<List<Note>>((ref) {
  return ref.watch(notesProvider).where((n) => n.isPinned).toList();
});

final unpinnedNotesProvider = Provider<List<Note>>((ref) {
  return ref.watch(notesProvider).where((n) => !n.isPinned).toList();
});
