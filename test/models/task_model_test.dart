import 'package:flutter_test/flutter_test.dart';
import 'package:captus_mobile/models/task.dart';

void main() {
  // ── TaskPriority ─────────────────────────────────────────────────────────────

  group('TaskPriorityX.fromBackend', () {
    test('maps integer 1 to high', () {
      expect(TaskPriorityX.fromBackend(1), TaskPriority.high);
    });

    test('maps integer 2 to medium', () {
      expect(TaskPriorityX.fromBackend(2), TaskPriority.medium);
    });

    test('maps integer 3 to low', () {
      expect(TaskPriorityX.fromBackend(3), TaskPriority.low);
    });

    test('maps string "alta" to high', () {
      expect(TaskPriorityX.fromBackend('alta'), TaskPriority.high);
    });

    test('maps string "media" to medium', () {
      expect(TaskPriorityX.fromBackend('media'), TaskPriority.medium);
    });

    test('maps string "low" to low', () {
      expect(TaskPriorityX.fromBackend('low'), TaskPriority.low);
    });

    test('defaults to low for unknown values', () {
      expect(TaskPriorityX.fromBackend('unknown'), TaskPriority.low);
      expect(TaskPriorityX.fromBackend(null), TaskPriority.low);
      expect(TaskPriorityX.fromBackend(99), TaskPriority.low);
    });
  });

  group('TaskPriority.label', () {
    test('high has Spanish label "Alta"', () {
      expect(TaskPriority.high.label, 'Alta');
    });

    test('medium has Spanish label "Media"', () {
      expect(TaskPriority.medium.label, 'Media');
    });

    test('low has Spanish label "Baja"', () {
      expect(TaskPriority.low.label, 'Baja');
    });
  });

  // ── TaskModel.fromJson ────────────────────────────────────────────────────────

  group('TaskModel.fromJson', () {
    final Map<String, dynamic> fullJson = {
      'id': 'task-42',
      'title': 'Entregar proyecto de cálculo',
      'description': 'Incluye derivadas e integrales',
      'priority_id': 1,
      'due_date': '2099-12-31T23:59:59Z',
      'completed': false,
      'created_at': '2024-01-01T00:00:00Z',
      'subject': {'name': 'Cálculo Diferencial'},
      'subTasks': [
        {'id': 'st-1', 'title': 'Introducción', 'state': false},
        {'id': 'st-2', 'title': 'Desarrollo', 'state': true},
      ],
    };

    test('parses id correctly', () {
      final task = TaskModel.fromJson(fullJson);
      expect(task.id, 'task-42');
    });

    test('parses title correctly', () {
      final task = TaskModel.fromJson(fullJson);
      expect(task.title, 'Entregar proyecto de cálculo');
    });

    test('parses description correctly', () {
      final task = TaskModel.fromJson(fullJson);
      expect(task.description, 'Incluye derivadas e integrales');
    });

    test('parses priority_id 1 as high', () {
      final task = TaskModel.fromJson(fullJson);
      expect(task.priority, TaskPriority.high);
    });

    test('parses due_date correctly', () {
      final task = TaskModel.fromJson(fullJson);
      expect(task.dueDate, isNotNull);
      expect(task.dueDate!.year, 2099);
    });

    test('parses completed = false', () {
      final task = TaskModel.fromJson(fullJson);
      expect(task.completed, false);
    });

    test('parses subject name', () {
      final task = TaskModel.fromJson(fullJson);
      expect(task.subjectName, 'Cálculo Diferencial');
    });

    test('parses subtasks list', () {
      final task = TaskModel.fromJson(fullJson);
      expect(task.subtasks, hasLength(2));
      expect(task.subtasks[0].title, 'Introducción');
      expect(task.subtasks[1].isCompleted, true);
    });

    test('handles missing optional fields gracefully', () {
      final task = TaskModel.fromJson({'id': '1', 'title': 'Minimal'});
      expect(task.id, '1');
      expect(task.title, 'Minimal');
      expect(task.description, isNull);
      expect(task.dueDate, isNull);
      expect(task.subtasks, isEmpty);
    });

    test('id is converted to string when numeric', () {
      final task = TaskModel.fromJson({'id': 99, 'title': 'Task'});
      expect(task.id, '99');
    });

    test('completed task gets TaskStatus.completed', () {
      final task = TaskModel.fromJson({
        'id': '1',
        'title': 'Done',
        'completed': true,
        'due_date': '2020-01-01T00:00:00Z',
      });
      expect(task.status, TaskStatus.completed);
    });

    test('past-due pending task gets TaskStatus.overdue', () {
      final task = TaskModel.fromJson({
        'id': '1',
        'title': 'Late',
        'completed': false,
        'due_date': '2000-01-01T00:00:00Z',
      });
      expect(task.status, TaskStatus.overdue);
    });

    test('future pending task gets TaskStatus.pending', () {
      final task = TaskModel.fromJson({
        'id': '1',
        'title': 'Future',
        'completed': false,
        'due_date': '2099-01-01T00:00:00Z',
      });
      expect(task.status, TaskStatus.pending);
    });
  });

  // ── TaskModel.isOverdue ───────────────────────────────────────────────────────

  group('TaskModel.isOverdue', () {
    TaskModel makeTask({required DateTime? dueDate, required bool completed}) {
      return TaskModel(
        id: 't1',
        title: 'Test',
        priority: TaskPriority.low,
        status: completed ? TaskStatus.completed : TaskStatus.pending,
        createdAt: DateTime.now(),
        dueDate: dueDate,
        completed: completed,
      );
    }

    test('returns true when due date is in the past and not completed', () {
      final task = makeTask(
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        completed: false,
      );
      expect(task.isOverdue, true);
    });

    test('returns false when completed even if past due', () {
      final task = makeTask(
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        completed: true,
      );
      expect(task.isOverdue, false);
    });

    test('returns false when due date is in the future', () {
      final task = makeTask(
        dueDate: DateTime.now().add(const Duration(days: 1)),
        completed: false,
      );
      expect(task.isOverdue, false);
    });

    test('returns false when due date is null', () {
      final task = makeTask(dueDate: null, completed: false);
      expect(task.isOverdue, false);
    });
  });

  // ── TaskModel.copyWith ────────────────────────────────────────────────────────

  group('TaskModel.copyWith', () {
    final original = TaskModel(
      id: 'task-1',
      title: 'Original',
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      createdAt: DateTime(2024, 1, 1),
      completed: false,
    );

    test('marks task as completed without mutating original', () {
      final updated = original.copyWith(
        completed: true,
        status: TaskStatus.completed,
      );
      expect(updated.completed, true);
      expect(updated.status, TaskStatus.completed);
      // Original unchanged
      expect(original.completed, false);
      expect(original.status, TaskStatus.pending);
    });

    test('preserves unchanged fields', () {
      final updated = original.copyWith(completed: true);
      expect(updated.id, original.id);
      expect(updated.title, original.title);
      expect(updated.priority, original.priority);
    });
  });

  // ── TaskModel.completedSubtasks ───────────────────────────────────────────────

  group('TaskModel.completedSubtasks', () {
    test('counts only completed subtasks', () {
      final task = TaskModel(
        id: 't',
        title: 'T',
        priority: TaskPriority.low,
        status: TaskStatus.pending,
        createdAt: DateTime.now(),
        subtasks: const [
          SubTask(id: 's1', title: 'A', isCompleted: true),
          SubTask(id: 's2', title: 'B', isCompleted: false),
          SubTask(id: 's3', title: 'C', isCompleted: true),
        ],
      );
      expect(task.completedSubtasks, 2);
    });

    test('returns 0 when there are no subtasks', () {
      final task = TaskModel(
        id: 't',
        title: 'T',
        priority: TaskPriority.low,
        status: TaskStatus.pending,
        createdAt: DateTime.now(),
      );
      expect(task.completedSubtasks, 0);
    });
  });

  // ── TaskModel.mockList stub ───────────────────────────────────────────────────

  group('TaskModel.mockList', () {
    test('returns an empty list (migration stub)', () {
      expect(TaskModel.mockList, isEmpty);
      expect(TaskModel.mockList, isA<List<TaskModel>>());
    });
  });
}
