import 'package:flutter_test/flutter_test.dart';
import 'package:captus_mobile/models/task.dart';

void main() {
  group('TaskModel', () {
    test('should create TaskModel with required fields', () {
      final task = TaskModel(
        id: 1,
        title: 'Test Task',
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        createdAt: DateTime(2028, 5, 15),
      );

      expect(task.id, 1);
      expect(task.title, 'Test Task');
      expect(task.priority, TaskPriority.high);
      expect(task.status, TaskStatus.pending);
      expect(task.completed, false);
      expect(task.subtasks, isEmpty);
      expect(task.attachments, isEmpty);
    });

    test('should create TaskModel with all fields', () {
      final dueDate = DateTime(2028, 6, 1);
      final createdAt = DateTime(2028, 5, 15);
      final subtask = SubTask(id: 'st1', title: 'Subtask 1');
      final task = TaskModel(
        id: 1,
        title: 'Test Task',
        description: 'Description',
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        dueDate: dueDate,
        courseId: 'c1',
        courseName: 'Course 1',
        subjectName: 'Subject 1',
        groupId: 'g1',
        subtasks: [subtask],
        attachments: ['file.pdf'],
        createdAt: createdAt,
        completed: false,
        categoryId: 1,
        categoryName: 'General',
        parentTaskId: null,
      );

      expect(task.description, 'Description');
      expect(task.dueDate, dueDate);
      expect(task.courseId, 'c1');
      expect(task.courseName, 'Course 1');
      expect(task.subjectName, 'Subject 1');
      expect(task.groupId, 'g1');
      expect(task.subtasks, hasLength(1));
      expect(task.attachments, ['file.pdf']);
      expect(task.categoryId, 1);
      expect(task.categoryName, 'General');
    });

    test('should compute isOverdue correctly', () {
      final pastDue = DateTime.now().subtract(const Duration(days: 1));
      final futureDue = DateTime.now().add(const Duration(days: 1));

      final overdueTask = TaskModel(
        title: 'Overdue',
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        dueDate: pastDue,
        createdAt: DateTime.now(),
      );

      final futureTask = TaskModel(
        title: 'Future',
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        dueDate: futureDue,
        createdAt: DateTime.now(),
      );

      final completedTask = TaskModel(
        title: 'Completed',
        priority: TaskPriority.high,
        status: TaskStatus.completed,
        dueDate: pastDue,
        createdAt: DateTime.now(),
        completed: true,
      );

      final noDueTask = TaskModel(
        title: 'No Due',
        priority: TaskPriority.low,
        status: TaskStatus.pending,
        createdAt: DateTime.now(),
      );

      expect(overdueTask.isOverdue, isTrue);
      expect(futureTask.isOverdue, isFalse);
      expect(completedTask.isOverdue, isFalse);
      expect(noDueTask.isOverdue, isFalse);
    });

    test('should compute completedSubtasks correctly', () {
      final task = TaskModel(
        title: 'Test',
        priority: TaskPriority.low,
        status: TaskStatus.pending,
        createdAt: DateTime.now(),
        subtasks: [
          SubTask(id: '1', title: 'A', isCompleted: true),
          SubTask(id: '2', title: 'B', isCompleted: false),
          SubTask(id: '3', title: 'C', isCompleted: true),
        ],
      );

      expect(task.completedSubtasks, 2);
    });

    test('should compute timeUntilDue', () {
      final future = DateTime.now().add(const Duration(days: 3));
      final task = TaskModel(
        title: 'Test',
        priority: TaskPriority.low,
        status: TaskStatus.pending,
        dueDate: future,
        createdAt: DateTime.now(),
      );

      expect(task.timeUntilDue, isNotNull);
      expect(task.timeUntilDue!.inDays, greaterThanOrEqualTo(2));
    });

    test('should return null timeUntilDue when no dueDate', () {
      final task = TaskModel(
        title: 'Test',
        priority: TaskPriority.low,
        status: TaskStatus.pending,
        createdAt: DateTime.now(),
      );

      expect(task.timeUntilDue, isNull);
    });

    test('should compute contextLabel from courseName', () {
      final task = TaskModel(
        title: 'Test',
        priority: TaskPriority.low,
        status: TaskStatus.pending,
        createdAt: DateTime.now(),
        courseName: 'Course',
        subjectName: 'Subject',
      );

      expect(task.contextLabel, 'Course');
    });

    test('should compute contextLabel from subjectName when no courseName', () {
      final task = TaskModel(
        title: 'Test',
        priority: TaskPriority.low,
        status: TaskStatus.pending,
        createdAt: DateTime.now(),
        subjectName: 'Subject',
      );

      expect(task.contextLabel, 'Subject');
    });

    test('should convert to JSON and back', () {
      final dueDate = DateTime(2028, 6, 1);
      final createdAt = DateTime(2028, 5, 15);
      final task = TaskModel(
        id: 1,
        title: 'Test Task',
        description: 'Description',
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        dueDate: dueDate,
        courseId: 'c1',
        subtasks: [
          SubTask(id: 'st1', title: 'Sub1', isCompleted: true),
        ],
        createdAt: createdAt,
      );

      final json = task.toJson();
      final restored = TaskModel.fromJson(json);

      expect(restored.id, task.id);
      expect(restored.title, task.title);
      expect(restored.description, task.description);
      expect(restored.priority, task.priority);
      expect(restored.status, task.status);
      expect(restored.dueDate!.toIso8601String(), dueDate.toIso8601String());
      expect(restored.subtasks.length, task.subtasks.length);
    });

    test('should handle missing fields in JSON', () {
      final json = {'title': 'Minimal Task'};
      final task = TaskModel.fromJson(json);

      expect(task.title, 'Minimal Task');
      expect(task.priority, TaskPriority.low);
      expect(task.completed, false);
      expect(task.subtasks, isEmpty);
    });

    test('should handle null values in JSON', () {
      final json = {
        'id': null,
        'title': null,
        'description': null,
        'priority_id': null,
        'completed': null,
        'due_date': null,
        'subtasks': null,
      };

      final task = TaskModel.fromJson(json);

      expect(task.id, null);
      expect(task.title, '');
      expect(task.description, null);
      expect(task.priority, TaskPriority.low);
      expect(task.completed, false);
      expect(task.subtasks, isEmpty);
    });

    test('copyWith should preserve unchanged fields', () {
      final task = TaskModel(
        id: 1,
        title: 'Original Title',
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        createdAt: DateTime(2028, 5, 15),
      );

      final updated = task.copyWith(status: TaskStatus.completed, completed: true);

      expect(updated.id, task.id);
      expect(updated.title, task.title);
      expect(updated.priority, task.priority);
      expect(updated.status, TaskStatus.completed);
      expect(updated.completed, true);
    });

    test('should parse priority from backend int values', () {
      expect(TaskPriorityX.fromBackend(1), TaskPriority.high);
      expect(TaskPriorityX.fromBackend(2), TaskPriority.medium);
      expect(TaskPriorityX.fromBackend(3), TaskPriority.low);
      expect(TaskPriorityX.fromBackend(99), TaskPriority.low);
    });

    test('should parse priority from backend string values', () {
      expect(TaskPriorityX.fromBackend('alta'), TaskPriority.high);
      expect(TaskPriorityX.fromBackend('high'), TaskPriority.high);
      expect(TaskPriorityX.fromBackend('media'), TaskPriority.medium);
      expect(TaskPriorityX.fromBackend('medium'), TaskPriority.medium);
      expect(TaskPriorityX.fromBackend('baja'), TaskPriority.low);
      expect(TaskPriorityX.fromBackend('low'), TaskPriority.low);
      expect(TaskPriorityX.fromBackend('unknown'), TaskPriority.low);
    });

    test('should have correct priority labels', () {
      expect(TaskPriority.high.label, 'Alta');
      expect(TaskPriority.medium.label, 'Media');
      expect(TaskPriority.low.label, 'Baja');
    });

    test('SubTask should create with required fields', () {
      const sub = SubTask(id: 'st1', title: 'Test Sub');

      expect(sub.id, 'st1');
      expect(sub.title, 'Test Sub');
      expect(sub.isCompleted, false);
    });

    test('SubTask should convert to JSON', () {
      const sub = SubTask(id: 'st1', title: 'Test', isCompleted: true);

      final json = sub.toJson();

      expect(json['id'], 'st1');
      expect(json['title'], 'Test');
      expect(json['completed'], true);
    });

    test('SubTask copyWith should update isCompleted', () {
      const sub = SubTask(id: 'st1', title: 'Test');

      final updated = sub.copyWith(isCompleted: true);

      expect(updated.id, 'st1');
      expect(updated.title, 'Test');
      expect(updated.isCompleted, true);
    });

    test('SubTask fromJson should use correct keys', () {
      final json = {'id_SubTask': 'st1', 'title': 'Sub', 'state': true};
      final sub = SubTask.fromJson(json);

      expect(sub.id, 'st1');
      expect(sub.title, 'Sub');
      expect(sub.isCompleted, true);
    });
  });
}
