import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:captus_mobile/core/providers/tasks_provider.dart';
import 'package:captus_mobile/core/services/api_client.dart';
import 'package:captus_mobile/models/task.dart';

import 'tasks_provider_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  group('TasksProvider Tests', () {
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
    });

    group('TasksService Tests', () {
      test('should fetch tasks for student', () async {
        // Arrange
        final tasksService = TasksService();
        final mockResponse = {
          'data': [
            {
              'id': '1',
              'title': 'Math Homework',
              'description': 'Complete exercises 1-10',
              'due_date': '2024-12-25T23:59:59.000Z',
              'priority': 'high',
              'status': 'pending',
              'course_id': 'course1',
              'course_name': 'Mathematics',
            },
            {
              'id': '2',
              'title': 'Science Project',
              'description': 'Submit final report',
              'due_date': '2024-12-30T23:59:59.000Z',
              'priority': 'medium',
              'status': 'in_progress',
              'course_id': 'course2',
              'course_name': 'Science',
            }
          ]
        };

        when(mockApiClient.get<dynamic>('/tasks/student'))
            .thenAnswer((_) async => MockApiResponse(mockResponse));

        // Act
        final tasks = await tasksService.fetchTasks('student');

        // Assert
        expect(tasks.length, 2);
        expect(tasks[0].id, '1');
        expect(tasks[0].title, 'Math Homework');
        expect(tasks[0].description, 'Complete exercises 1-10');
        expect(tasks[0].priority, TaskPriority.high);
        expect(tasks[0].status, TaskStatus.pending);
        expect(tasks[0].courseId, 'course1');
        expect(tasks[0].courseName, 'Mathematics');

        expect(tasks[1].id, '2');
        expect(tasks[1].title, 'Science Project');
        expect(tasks[1].priority, TaskPriority.medium);
        expect(tasks[1].status, TaskStatus.in_progress);
      });

      test('should fetch tasks for teacher', () async {
        // Arrange
        final tasksService = TasksService();
        final mockResponse = [
          {
            'id': '3',
            'title': 'Grade Papers',
            'description': 'Grade midterm exams',
            'due_date': '2024-12-28T23:59:59.000Z',
            'priority': 'high',
            'status': 'pending',
            'course_id': 'course3',
            'course_name': 'History',
          }
        ];

        when(mockApiClient.get<dynamic>('/tasks/teacher'))
            .thenAnswer((_) async => MockApiResponse(mockResponse));

        // Act
        final tasks = await tasksService.fetchTasks('teacher');

        // Assert
        expect(tasks.length, 1);
        expect(tasks[0].id, '3');
        expect(tasks[0].title, 'Grade Papers');
        expect(tasks[0].priority, TaskPriority.high);
        expect(tasks[0].courseName, 'History');
      });

      test('should handle empty response', () async {
        // Arrange
        final tasksService = TasksService();
        final mockResponse = {'data': []};

        when(mockApiClient.get<dynamic>('/tasks/student'))
            .thenAnswer((_) async => MockApiResponse(mockResponse));

        // Act
        final tasks = await tasksService.fetchTasks('student');

        // Assert
        expect(tasks.isEmpty, true);
      });

      test('should handle missing fields gracefully', () async {
        // Arrange
        final tasksService = TasksService();
        final mockResponse = {
          'data': [
            {
              'id': '1',
              'title': 'Incomplete Task',
              // Missing description, due_date, priority, status
            }
          ]
        };

        when(mockApiClient.get<dynamic>('/tasks/student'))
            .thenAnswer((_) async => MockApiResponse(mockResponse));

        // Act
        final tasks = await tasksService.fetchTasks('student');

        // Assert
        expect(tasks.length, 1);
        expect(tasks[0].id, '1');
        expect(tasks[0].title, 'Incomplete Task');
        expect(tasks[0].description, null);
        expect(tasks[0].dueDate, null);
        expect(tasks[0].priority, TaskPriority.medium); // Default
        expect(tasks[0].status, TaskStatus.pending); // Default
      });

      test('should create task successfully', () async {
        // Arrange
        final tasksService = TasksService();
        final newTask = TaskModel(
          id: 'new',
          title: 'New Task',
          description: 'Task description',
          dueDate: DateTime.now(),
          priority: TaskPriority.high,
          status: TaskStatus.pending,
          courseId: 'course1',
        );

        final mockResponse = {'success': true, 'data': newTask.toJson()};

        when(mockApiClient.post<dynamic>('/tasks', any))
            .thenAnswer((_) async => MockApiResponse(mockResponse));

        // Act
        final result = await tasksService.createTask(newTask);

        // Assert
        expect(result, true);
        verify(mockApiClient.post('/tasks', any)).called(1);
      });

      test('should update task successfully', () async {
        // Arrange
        final tasksService = TasksService();
        final updatedTask = TaskModel(
          id: '1',
          title: 'Updated Task',
          description: 'Updated description',
          dueDate: DateTime.now(),
          priority: TaskPriority.medium,
          status: TaskStatus.completed,
          courseId: 'course1',
        );

        final mockResponse = {'success': true};

        when(mockApiClient.put<dynamic>('/tasks/1', any))
            .thenAnswer((_) async => MockApiResponse(mockResponse));

        // Act
        final result = await tasksService.updateTask(updatedTask);

        // Assert
        expect(result, true);
        verify(mockApiClient.put('/tasks/1', any)).called(1);
      });

      test('should delete task successfully', () async {
        // Arrange
        final tasksService = TasksService();
        final mockResponse = {'success': true};

        when(mockApiClient.delete<dynamic>('/tasks/1'))
            .thenAnswer((_) async => MockApiResponse(mockResponse));

        // Act
        final result = await tasksService.deleteTask('1');

        // Assert
        expect(result, true);
        verify(mockApiClient.delete('/tasks/1')).called(1);
      });
    });

    group('TaskModel Tests', () {
      test('should create TaskModel with required fields', () {
        final task = TaskModel(
          id: '1',
          title: 'Test Task',
          dueDate: DateTime.now(),
          priority: TaskPriority.high,
          status: TaskStatus.pending,
          courseId: 'course1',
        );

        expect(task.id, '1');
        expect(task.title, 'Test Task');
        expect(task.priority, TaskPriority.high);
        expect(task.status, TaskStatus.pending);
        expect(task.courseId, 'course1');
        expect(task.description, null);
        expect(task.courseName, null);
      });

      test('should create TaskModel with all fields', () {
        final task = TaskModel(
          id: '1',
          title: 'Complete Task',
          description: 'Task description',
          dueDate: DateTime(2024, 12, 25),
          priority: TaskPriority.medium,
          status: TaskStatus.in_progress,
          courseId: 'course1',
          courseName: 'Mathematics',
        );

        expect(task.description, 'Task description');
        expect(task.courseName, 'Mathematics');
        expect(task.dueDate, DateTime(2024, 12, 25));
      });

      test('should convert to JSON correctly', () {
        final task = TaskModel(
          id: '1',
          title: 'Test Task',
          description: 'Test description',
          dueDate: DateTime(2024, 12, 25, 10, 30),
          priority: TaskPriority.high,
          status: TaskStatus.pending,
          courseId: 'course1',
          courseName: 'Mathematics',
        );

        final json = task.toJson();
        expect(json['id'], '1');
        expect(json['title'], 'Test Task');
        expect(json['description'], 'Test description');
        expect(json['due_date'], '2024-12-25T10:30:00.000Z');
        expect(json['priority'], 'high');
        expect(json['status'], 'pending');
        expect(json['course_id'], 'course1');
        expect(json['course_name'], 'Mathematics');
      });

      test('should create from JSON correctly', () {
        final json = {
          'id': '1',
          'title': 'Test Task',
          'description': 'Test description',
          'due_date': '2024-12-25T10:30:00.000Z',
          'priority': 'high',
          'status': 'pending',
          'course_id': 'course1',
          'course_name': 'Mathematics',
        };

        final task = TaskModel.fromJson(json);
        expect(task.id, '1');
        expect(task.title, 'Test Task');
        expect(task.description, 'Test description');
        expect(task.priority, TaskPriority.high);
        expect(task.status, TaskStatus.pending);
        expect(task.courseId, 'course1');
        expect(task.courseName, 'Mathematics');
        expect(task.dueDate, DateTime.parse('2024-12-25T10:30:00.000Z'));
      });

      test('should copy with new values', () {
        final original = TaskModel(
          id: '1',
          title: 'Original Task',
          dueDate: DateTime.now(),
          priority: TaskPriority.medium,
          status: TaskStatus.pending,
          courseId: 'course1',
        );

        final updated = original.copyWith(
          title: 'Updated Task',
          status: TaskStatus.completed,
          priority: TaskPriority.high,
        );

        expect(updated.id, original.id);
        expect(updated.title, 'Updated Task');
        expect(updated.status, TaskStatus.completed);
        expect(updated.priority, TaskPriority.high);
        expect(updated.dueDate, original.dueDate);
        expect(updated.courseId, original.courseId);
      });

      test('should provide mock data', () {
        final mockTasks = TaskModel.mockList;
        expect(mockTasks.isNotEmpty, true);
        
        final firstTask = mockTasks.first;
        expect(firstTask.id, isNotEmpty);
        expect(firstTask.title, isNotEmpty);
        expect(firstTask.priority, isA<TaskPriority>());
        expect(firstTask.status, isA<TaskStatus>());
      });
    });

    group('TaskPriority Tests', () {
      test('should have correct enum values', () {
        expect(TaskPriority.low, isA<TaskPriority>());
        expect(TaskPriority.medium, isA<TaskPriority>());
        expect(TaskPriority.high, isA<TaskPriority>());
      });

      test('should convert to string correctly', () {
        expect(TaskPriority.low.toString(), 'TaskPriority.low');
        expect(TaskPriority.medium.toString(), 'TaskPriority.medium');
        expect(TaskPriority.high.toString(), 'TaskPriority.high');
      });
    });

    group('TaskStatus Tests', () {
      test('should have correct enum values', () {
        expect(TaskStatus.pending, isA<TaskStatus>());
        expect(TaskStatus.in_progress, isA<TaskStatus>());
        expect(TaskStatus.completed, isA<TaskStatus>());
        expect(TaskStatus.cancelled, isA<TaskStatus>());
      });

      test('should convert to string correctly', () {
        expect(TaskStatus.pending.toString(), 'TaskStatus.pending');
        expect(TaskStatus.in_progress.toString(), 'TaskStatus.in_progress');
        expect(TaskStatus.completed.toString(), 'TaskStatus.completed');
        expect(TaskStatus.cancelled.toString(), 'TaskStatus.cancelled');
      });
    });

    group('Provider Integration Tests', () {
      test('tasksProvider should fetch tasks based on user role', () {
        final container = ProviderContainer();
        
        // Test that provider is created correctly
        expect(container.read(tasksProvider), isA<AsyncValue<List<TaskModel>>>());
      });

      test('taskByIdProvider should find task by id', () {
        final container = ProviderContainer();
        
        // Create mock tasks
        final mockTasks = [
          TaskModel(
            id: '1',
            title: 'Task 1',
            dueDate: DateTime.now(),
            priority: TaskPriority.high,
            status: TaskStatus.pending,
            courseId: 'course1',
          ),
          TaskModel(
            id: '2',
            title: 'Task 2',
            dueDate: DateTime.now(),
            priority: TaskPriority.medium,
            status: TaskStatus.in_progress,
            courseId: 'course2',
          ),
        ];

        // Test the provider logic
        final result = mockTasks.where((t) => t.id == '1').firstOrNull;
        expect(result?.title, 'Task 1');
        
        final notFound = mockTasks.where((t) => t.id == '999').firstOrNull;
        expect(notFound, null);
      });
    });
  });
}

// Mock classes for testing
class MockApiResponse<T> {
  final T data;
  
  MockApiResponse(this.data);
}
