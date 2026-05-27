/// Integration tests for SupabaseService contract behaviour.
///
/// These tests validate the service layer contract (interface, data mapping,
/// error handling) WITHOUT making real network calls. Real DB integration
/// tests live in integration_test/ and require a running environment.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:captus_mobile/core/services/local_storage_service.dart';
import 'package:captus_mobile/models/task.dart';
import 'package:captus_mobile/models/note.dart';
import 'package:captus_mobile/models/user.dart';

void main() {
  setUpAll(() async {
    dotenv.testLoad(mergeWith: {
      'API_BASE_URL': 'http://localhost:3000/api',
      'SUPABASE_URL': 'https://stub.supabase.co',
      'SUPABASE_ANON_KEY': 'stub-key',
    });
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.initialize();
  });

  // ── TaskModel ↔ JSON mapping contract ─────────────────────────────────────

  group('TaskModel — JSON mapping contract', () {
    test('fromJson maps all Supabase field names correctly', () {
      final json = {
        'id': 42,
        'title': 'Parcial de Cálculo',
        'description': 'Cap 3-5 del libro',
        'priority_id': 1,
        'completed': false,
        'due_date': '2026-06-15T10:00:00.000Z',
        'created_at': '2026-05-01T08:00:00.000Z',
        'category_id': 3,
        'subtasks': [],
      };

      final task = TaskModel.fromJson(json);

      expect(task.id, 42);
      expect(task.title, 'Parcial de Cálculo');
      expect(task.description, 'Cap 3-5 del libro');
      expect(task.priority, TaskPriority.high);
      expect(task.completed, false);
      expect(task.dueDate, isNotNull);
      expect(task.categoryId, 3);
      expect(task.subtasks, isEmpty);
    });

    test('fromJson handles legacy "endDate" field for dueDate', () {
      final json = {
        'title': 'Legacy task',
        'endDate': '2026-07-01T00:00:00.000Z',
        'created_at': '2026-05-01T00:00:00.000Z',
      };

      final task = TaskModel.fromJson(json);
      expect(task.dueDate, isNotNull);
    });

    test('fromJson maps subtasks using id_SubTask and state keys', () {
      final json = {
        'id': 1,
        'title': 'Parent task',
        'created_at': '2026-05-01T00:00:00.000Z',
        'subtasks': [
          {'id_SubTask': 'st1', 'title': 'Subtarea 1', 'state': true},
          {'id_SubTask': 'st2', 'title': 'Subtarea 2', 'state': false},
        ],
      };

      final task = TaskModel.fromJson(json);
      expect(task.subtasks.length, 2);
      expect(task.subtasks[0].id, 'st1');
      expect(task.subtasks[0].isCompleted, true);
      expect(task.subtasks[1].isCompleted, false);
    });

    test('fromJson maps alternative "subTasks" casing', () {
      final json = {
        'title': 'Task',
        'created_at': '2026-05-01T00:00:00.000Z',
        'subTasks': [
          {'id': 'x1', 'title': 'Sub', 'state': false},
        ],
      };

      final task = TaskModel.fromJson(json);
      expect(task.subtasks.length, 1);
    });

    test('toJson produces round-trip compatible output', () {
      final original = TaskModel(
        id: 7,
        title: 'Round-trip task',
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        createdAt: DateTime(2026, 5, 1),
        completed: false,
      );

      final json = original.toJson();
      final restored = TaskModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.priority, original.priority);
      expect(restored.completed, original.completed);
    });

    test('status is computed as overdue when past due and not completed', () {
      final json = {
        'title': 'Vencida',
        'due_date': '2020-01-01T00:00:00.000Z',
        'completed': false,
        'created_at': '2020-01-01T00:00:00.000Z',
      };

      final task = TaskModel.fromJson(json);
      expect(task.isOverdue, isTrue);
      expect(task.status, TaskStatus.overdue);
    });

    test('status is completed when completed=true regardless of due date', () {
      final json = {
        'title': 'Completada vencida',
        'due_date': '2020-01-01T00:00:00.000Z',
        'completed': true,
        'created_at': '2020-01-01T00:00:00.000Z',
      };

      final task = TaskModel.fromJson(json);
      expect(task.status, TaskStatus.completed);
      expect(task.isOverdue, isFalse);
    });
  });

  // ── NoteModel ↔ JSON mapping contract ─────────────────────────────────────

  group('NoteModel — JSON mapping contract', () {
    test('fromJson maps all fields correctly', () {
      final json = {
        'id': 5,
        'user_id': 'u1',
        'title': 'Apuntes de clase',
        'content': 'Contenido de la nota',
        'subject': 'Matemáticas',
        'is_pinned': true,
        'created_at': '2026-05-10T14:00:00.000Z',
      };

      final note = NoteModel.fromJson(json);
      expect(note.id, 5);
      expect(note.title, 'Apuntes de clase');
      expect(note.content, 'Contenido de la nota');
      expect(note.subject, 'Matemáticas');
      expect(note.isPinned, true);
    });

    test('fromJson handles is_pinned=false', () {
      final json = {
        'id': 6,
        'user_id': 'u1',
        'title': 'Nota no fijada',
        'content': '',
        'is_pinned': false,
        'created_at': '2026-05-10T14:00:00.000Z',
      };

      final note = NoteModel.fromJson(json);
      expect(note.isPinned, false);
    });
  });

  // ── UserModel ↔ JSON mapping contract ─────────────────────────────────────

  group('UserModel — JSON mapping contract', () {
    test('fromJson maps all fields', () {
      final json = {
        'id': 'u-abc123',
        'name': 'Ana Martínez',
        'email': 'ana@example.com',
        'university': 'Universidad Popular del Cesar',
        'career': 'Ingeniería de Sistemas',
        'semester': 6,
        'role': 'student',
        'avatarUrl': 'https://cdn.example.com/avatar.png',
        'bio': 'Estudiante de sistemas',
        'createdAt': '2025-01-15T00:00:00.000',
        'updatedAt': '2026-05-01T00:00:00.000',
      };

      final user = UserModel.fromJson(json);
      expect(user.id, 'u-abc123');
      expect(user.name, 'Ana Martínez');
      expect(user.email, 'ana@example.com');
      expect(user.role, UserRole.student);
      expect(user.semester, 6);
    });

    test('role defaults gracefully for unknown role', () {
      final json = {
        'id': 'u1',
        'name': 'Test',
        'email': 'test@test.com',
        'role': 'superuser_unknown',
        'createdAt': '2026-01-01T00:00:00.000',
        'updatedAt': '2026-01-01T00:00:00.000',
      };

      // Should not throw
      expect(() => UserModel.fromJson(json), returnsNormally);
    });
  });

  // ── LocalStorageService — persistence contract ─────────────────────────────

  group('LocalStorageService — persistence contract', () {
    test('stores and retrieves a string value', () async {
      await LocalStorageService.setString('test_key', 'test_value');
      final result = LocalStorageService.getString('test_key');
      expect(result, 'test_value');
    });

    test('returns null for missing key', () {
      final result = LocalStorageService.getString('nonexistent_key_xyz');
      expect(result, isNull);
    });

    test('overwrites existing value', () async {
      await LocalStorageService.setString('overwrite_key', 'first');
      await LocalStorageService.setString('overwrite_key', 'second');
      expect(LocalStorageService.getString('overwrite_key'), 'second');
    });

    test('remove deletes key', () async {
      await LocalStorageService.setString('delete_me', 'value');
      await LocalStorageService.remove('delete_me');
      expect(LocalStorageService.getString('delete_me'), isNull);
    });

    test('stores and retrieves a bool value', () async {
      await LocalStorageService.setBool('bool_key', true);
      expect(LocalStorageService.getBool('bool_key'), isTrue);
    });

    test('getBool returns false for missing key', () {
      expect(LocalStorageService.getBool('missing_bool_xyz'), isFalse);
    });

    test('stores and retrieves an int value', () async {
      await LocalStorageService.setInt('int_key', 42);
      expect(LocalStorageService.getInt('int_key'), 42);
    });

    test('getInt returns 0 for missing key', () {
      expect(LocalStorageService.getInt('missing_int_xyz'), 0);
    });

    test('setJson / getJson round-trip', () async {
      final data = {'name': 'Test', 'count': 7, 'active': true};
      await LocalStorageService.setJson('json_key', data);
      final result = LocalStorageService.getJson('json_key') as Map<String, dynamic>;
      expect(result['name'], 'Test');
      expect(result['count'], 7);
      expect(result['active'], true);
    });

    test('getJson returns null for missing key', () {
      expect(LocalStorageService.getJson('missing_json_xyz'), isNull);
    });

    test('userStreak round-trip', () async {
      await LocalStorageService.setUserStreak(15);
      expect(LocalStorageService.userStreak, 15);
    });

    test('onboardingCompleted flag', () async {
      await LocalStorageService.setOnboardingCompleted(true);
      expect(LocalStorageService.onboardingCompleted, isTrue);
    });
  });
}
