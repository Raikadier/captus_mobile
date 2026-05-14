import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/note.dart';
import 'auth_provider.dart';

class NotesService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<NoteModel>> fetchAll(String userId) async {
    final response = await _client
        .from('notes')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => NoteModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<NoteModel?> fetchById(int noteId) async {
    final response = await _client
        .from('notes')
        .select()
        .eq('id', noteId)
        .maybeSingle();

    if (response == null) return null;
    return NoteModel.fromJson(Map<String, dynamic>.from(response));
  }

  Future<NoteModel> create({
    required String userId,
    required String title,
    String? content,
    String? subject,
    bool isPinned = false,
  }) async {
    final now = DateTime.now().toIso8601String();

    final response = await _client
        .from('notes')
        .insert({
          'user_id': userId,
          'title': title,
          'content': content,
          'subject': subject,
          'is_pinned': isPinned,
          'created_at': now,
          'update_at': now,
        })
        .select()
        .single();

    return NoteModel.fromJson(Map<String, dynamic>.from(response));
  }

  Future<NoteModel?> update(int noteId, Map<String, dynamic> updates) async {
    final updateData = Map<String, dynamic>.from(updates);
    updateData['update_at'] = DateTime.now().toIso8601String();

    await _client
        .from('notes')
        .update(updateData)
        .eq('id', noteId);

    return fetchById(noteId);
  }

  Future<void> delete(int noteId) async {
    await _client.from('notes').delete().eq('id', noteId);
  }

  Future<NoteModel?> togglePin(int noteId, bool isPinned) async {
    return update(noteId, {'is_pinned': isPinned});
  }
}

final notesServiceProvider = Provider<NotesService>((ref) => NotesService());

class NotesNotifier extends AsyncNotifier<List<NoteModel>> {
  @override
  Future<List<NoteModel>> build() {
    final user = ref.watch(currentUserProvider);
    if (user == null) return Future.value([]);
    return ref.read(notesServiceProvider).fetchAll(user.id);
  }

  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(notesServiceProvider).fetchAll(user.id),
    );
  }

  Future<NoteModel?> create({
    required String title,
    String? content,
    String? subject,
    bool isPinned = false,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return null;

    try {
      final note = await ref.read(notesServiceProvider).create(
        userId: user.id,
        title: title,
        content: content,
        subject: subject,
        isPinned: isPinned,
      );

      state = state.whenData((notes) => [note, ...notes]);
      return note;
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> updateNote(int noteId, {
    String? title,
    String? content,
    String? subject,
    bool? isPinned,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (content != null) updates['content'] = content;
      if (subject != null) updates['subject'] = subject;
      if (isPinned != null) updates['is_pinned'] = isPinned;

      final updated = await ref.read(notesServiceProvider).update(noteId, updates);
      if (updated != null) {
        state = state.whenData(
          (notes) => notes.map((n) => n.id == noteId ? updated : n).toList(),
        );
      }
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> delete(int noteId) async {
    state = state.whenData(
      (notes) => notes.where((n) => n.id != noteId).toList(),
    );
    try {
      await ref.read(notesServiceProvider).delete(noteId);
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> togglePin(int noteId) async {
    final currentNotes = state.value;
    if (currentNotes == null) return;
    final currentNote = currentNotes.where((n) => n.id == noteId).firstOrNull;
    if (currentNote == null) return;

    final newPinned = !currentNote.isPinned;

    state = state.whenData(
      (notes) => notes.map((n) {
        if (n.id == noteId) {
          return n.copyWith(isPinned: newPinned, updateAt: DateTime.now());
        }
        return n;
      }).toList(),
    );

    try {
      await ref.read(notesServiceProvider).togglePin(noteId, newPinned);
    } catch (e) {
      await refresh();
      rethrow;
    }
  }
}

final notesNotifierProvider =
    AsyncNotifierProvider<NotesNotifier, List<NoteModel>>(NotesNotifier.new);

final pinnedNotesProvider = Provider.autoDispose<AsyncValue<List<NoteModel>>>((ref) {
  final notesAsync = ref.watch(notesNotifierProvider);
  return notesAsync.whenData(
    (notes) => notes.where((n) => n.isPinned).toList(),
  );
});

class NoteSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final noteSearchQueryProvider = NotifierProvider<NoteSearchNotifier, String>(
  NoteSearchNotifier.new,
);

final filteredNotesProvider = Provider.autoDispose<AsyncValue<List<NoteModel>>>((ref) {
  final notesAsync = ref.watch(notesNotifierProvider);
  final searchQuery = ref.watch(noteSearchQueryProvider).toLowerCase();

  return notesAsync.whenData((notes) {
    var filtered = notes.where((n) => 
      n.title.toLowerCase().contains(searchQuery) ||
      (n.content?.toLowerCase().contains(searchQuery) ?? false)
    ).toList();

    final pinned = filtered.where((n) => n.isPinned).toList();
    final notPinned = filtered.where((n) => !n.isPinned).toList();

    return [...pinned, ...notPinned];
  });
});

final noteByIdProvider = Provider.family<NoteModel?, int>((ref, noteId) {
  final notesAsync = ref.watch(notesNotifierProvider);
  return notesAsync.whenOrNull(
    data: (notes) {
      try {
        return notes.firstWhere((n) => n.id == noteId);
      } catch (_) {
        return null;
      }
    },
  );
});