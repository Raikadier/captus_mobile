import 'package:flutter_test/flutter_test.dart';
import 'package:captus_mobile/models/note.dart';

void main() {
  group('NoteModel', () {
    test('should create NoteModel with required fields', () {
      final createdAt = DateTime(2026, 5, 15);
      final note = NoteModel(
        createdAt: createdAt,
        userId: 'user-1',
        title: 'Apuntes de Clase',
      );

      expect(note.id, null);
      expect(note.createdAt, createdAt);
      expect(note.userId, 'user-1');
      expect(note.title, 'Apuntes de Clase');
      expect(note.content, null);
      expect(note.subject, null);
      expect(note.isPinned, false);
    });

    test('should create NoteModel with all fields', () {
      final createdAt = DateTime(2026, 5, 15);
      final updatedAt = DateTime(2026, 5, 16);
      final note = NoteModel(
        id: 1,
        createdAt: createdAt,
        updateAt: updatedAt,
        userId: 'user-1',
        title: 'Apuntes',
        content: 'Contenido de la nota.',
        subject: 'Matemáticas',
        isPinned: true,
      );

      expect(note.id, 1);
      expect(note.updateAt, updatedAt);
      expect(note.content, 'Contenido de la nota.');
      expect(note.subject, 'Matemáticas');
      expect(note.isPinned, true);
    });

    test('should convert to JSON and back', () {
      final createdAt = DateTime(2026, 5, 15);
      final note = NoteModel(
        id: 1,
        createdAt: createdAt,
        userId: 'user-1',
        title: 'Apuntes',
        content: 'Contenido',
        subject: 'Mate',
        isPinned: true,
      );

      final json = note.toJson();
      final restored = NoteModel.fromJson(json);

      expect(restored.id, note.id);
      expect(restored.createdAt.toIso8601String(), createdAt.toIso8601String());
      expect(restored.userId, note.userId);
      expect(restored.title, note.title);
      expect(restored.content, note.content);
      expect(restored.subject, note.subject);
      expect(restored.isPinned, note.isPinned);
    });

    test('fromJson should handle missing optional fields', () {
      final json = {
        'id': 1,
        'created_at': '2026-05-15T10:00:00.000',
        'user_id': 'user-1',
        'title': 'Nota',
        'content': null,
        'subject': null,
        'is_pinned': null,
      };

      final note = NoteModel.fromJson(json);

      expect(note.id, 1);
      expect(note.title, 'Nota');
      expect(note.content, null);
      expect(note.subject, null);
      expect(note.isPinned, false);
    });

    test('fromJson should handle missing is_pinned', () {
      final json = {
        'id': 1,
        'created_at': '2026-05-15T10:00:00.000',
        'user_id': 'user-1',
        'title': 'Nota',
      };

      final note = NoteModel.fromJson(json);

      expect(note.isPinned, false);
    });

    test('should handle null updateAt', () {
      final json = {
        'id': 1,
        'created_at': '2026-05-15T10:00:00.000',
        'user_id': 'user-1',
        'title': 'Nota',
        'update_at': null,
      };

      final note = NoteModel.fromJson(json);

      expect(note.updateAt, null);
    });

    test('copyWith should preserve unchanged fields', () {
      final createdAt = DateTime(2026, 5, 15);
      final note = NoteModel(
        id: 1,
        createdAt: createdAt,
        userId: 'user-1',
        title: 'Original Title',
        content: 'Original content',
        subject: 'Math',
        isPinned: true,
      );

      final updated = note.copyWith(title: 'Updated Title', isPinned: false);

      expect(updated.id, note.id);
      expect(updated.createdAt, note.createdAt);
      expect(updated.userId, note.userId);
      expect(updated.title, 'Updated Title');
      expect(updated.content, note.content);
      expect(updated.subject, note.subject);
      expect(updated.isPinned, false);
    });

    test('copyWith should update updateAt', () {
      final createdAt = DateTime(2026, 5, 15);
      final updatedAt = DateTime(2026, 5, 16);
      final note = NoteModel(
        id: 1,
        createdAt: createdAt,
        userId: 'user-1',
        title: 'Original',
      );

      final updated = note.copyWith(updateAt: updatedAt, title: 'Updated');

      expect(updated.updateAt, updatedAt);
      expect(updated.title, 'Updated');
    });

    test('color should return a Color from courseColors', () {
      final note = NoteModel(
        id: 1,
        createdAt: DateTime(2026, 5, 15),
        userId: 'user-1',
        title: 'Nota',
      );

      expect(note.color, isNotNull);
      expect(note.accentColor, isNotNull);
    });

    test('color should be deterministic for same id', () {
      final note1 = NoteModel(
        id: 42,
        createdAt: DateTime(2026, 5, 15),
        userId: 'user-1',
        title: 'A',
      );
      final note2 = NoteModel(
        id: 42,
        createdAt: DateTime(2026, 5, 15),
        userId: 'user-1',
        title: 'B',
      );

      expect(note1.color, note2.color);
      expect(note1.accentColor, note2.accentColor);
    });
  });
}
