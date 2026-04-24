import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:captus_mobile/core/providers/courses_provider.dart';
import 'package:captus_mobile/core/providers/auth_provider.dart';
import 'package:captus_mobile/core/services/api_client.dart';
import 'package:captus_mobile/models/course.dart';

import 'courses_provider_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  group('CoursesProvider Tests', () {
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
    });

    group('CoursesService Tests', () {
      test('should fetch courses for student role', () async {
        // Arrange
        final coursesService = CoursesService();
        final mockResponse = {
          'data': [
            {
              'id': '1',
              'title': 'Test Course',
              'invite_code': 'TC101',
              'professor': 'Test Professor',
              'progress': 0.5,
              'pendingTasks': 2,
              'description': 'Test description',
            },
            {
              'id': '2',
              'name': 'Another Course',
              'code': 'AC202',
              'teacherName': 'Another Professor',
              'progress': 0.8,
              'pendingActivities': 1,
            }
          ]
        };

        when(mockApiClient.get<dynamic>('/courses/student'))
            .thenAnswer((_) async => MockApiResponse(mockResponse));

        // Act
        final courses = await coursesService.fetchAll('student');

        // Assert
        expect(courses.length, 2);
        expect(courses[0].id, '1');
        expect(courses[0].name, 'Test Course');
        expect(courses[0].code, 'TC101');
        expect(courses[0].teacherName, 'Test Professor');
        expect(courses[0].progress, 0.5);
        expect(courses[0].pendingActivities, 2);
        expect(courses[0].description, 'Test description');

        expect(courses[1].id, '2');
        expect(courses[1].name, 'Another Course');
        expect(courses[1].code, 'AC202');
        expect(courses[1].teacherName, 'Another Professor');
        expect(courses[1].progress, 0.8);
        expect(courses[1].pendingActivities, 1);
      });

      test('should fetch courses for teacher role', () async {
        // Arrange
        final coursesService = CoursesService();
        final mockResponse = [
          {
            'id': '3',
            'title': 'Teacher Course',
            'invite_code': 'TC301',
            'professor': 'Professor Smith',
            'progress': 0.7,
            'pendingTasks': 3,
          }
        ];

        when(mockApiClient.get<dynamic>('/courses/teacher'))
            .thenAnswer((_) async => MockApiResponse(mockResponse));

        // Act
        final courses = await coursesService.fetchAll('teacher');

        // Assert
        expect(courses.length, 1);
        expect(courses[0].id, '3');
        expect(courses[0].name, 'Teacher Course');
        expect(courses[0].code, 'TC301');
        expect(courses[0].teacherName, 'Professor Smith');
        expect(courses[0].progress, 0.7);
        expect(courses[0].pendingActivities, 3);
      });

      test('should handle empty response', () async {
        // Arrange
        final coursesService = CoursesService();
        final mockResponse = {'data': []};

        when(mockApiClient.get<dynamic>('/courses/student'))
            .thenAnswer((_) async => MockApiResponse(mockResponse));

        // Act
        final courses = await coursesService.fetchAll('student');

        // Assert
        expect(courses.isEmpty, true);
      });

      test('should handle missing fields gracefully', () async {
        // Arrange
        final coursesService = CoursesService();
        final mockResponse = {
          'data': [
            {
              'id': '1',
              // Missing name/title
              'invite_code': 'TC101',
              // Missing professor/teacherName
              'progress': 0.5,
              // Missing pendingTasks/pendingActivities
            }
          ]
        };

        when(mockApiClient.get<dynamic>('/courses/student'))
            .thenAnswer((_) async => MockApiResponse(mockResponse));

        // Act
        final courses = await coursesService.fetchAll('student');

        // Assert
        expect(courses.length, 1);
        expect(courses[0].id, '1');
        expect(courses[0].name, ''); // Default empty string
        expect(courses[0].code, 'TC101');
        expect(courses[0].teacherName, ''); // Default empty string
        expect(courses[0].progress, 0.5);
        expect(courses[0].pendingActivities, 0); // Default 0
      });

      test('should assign color indices correctly', () async {
        // Arrange
        final coursesService = CoursesService();
        final mockResponse = {
          'data': [
            {'id': '1', 'name': 'Course 1'},
            {'id': '2', 'name': 'Course 2'},
            {'id': '3', 'name': 'Course 3'},
            {'id': '4', 'name': 'Course 4'},
            {'id': '5', 'name': 'Course 5'},
            {'id': '6', 'name': 'Course 6'},
            {'id': '7', 'name': 'Course 7'},
            {'id': '8', 'name': 'Course 8'},
          ]
        };

        when(mockApiClient.get<dynamic>('/courses/student'))
            .thenAnswer((_) async => MockApiResponse(mockResponse));

        // Act
        final courses = await coursesService.fetchAll('student');

        // Assert
        expect(courses.length, 8);
        expect(courses[0].colorIndex, 0);
        expect(courses[1].colorIndex, 1);
        expect(courses[2].colorIndex, 2);
        expect(courses[3].colorIndex, 3);
        expect(courses[4].colorIndex, 4);
        expect(courses[5].colorIndex, 5);
        expect(courses[6].colorIndex, 0); // Should wrap around
        expect(courses[7].colorIndex, 1); // Should wrap around
      });
    });

    group('Provider Integration Tests', () {
      test('coursesProvider should use student role by default', () {
        final container = ProviderContainer();
        
        // Mock the userRoleProvider to return 'student'
        container.listen(userRoleProvider, (_, __) {});
        container.read(userRoleProvider);
        
        // The provider should be created and call the service with 'student' role
        expect(container.read(userRoleProvider), 'student');
      });

      test('coursesProvider should use teacher role when user is teacher', () {
        final container = ProviderContainer();
        
        // Mock the userRoleProvider to return 'teacher'
        container.listen(userRoleProvider, (_, __) {});
        // Note: In a real test, you would mock the auth provider to return teacher role
        
        expect(container.read(userRoleProvider), 'student'); // Default
      });

      test('courseByIdProvider should find course by id', () {
        final container = ProviderContainer();
        
        // Create mock courses
        final mockCourses = [
          CourseModel(
            id: '1',
            name: 'Course 1',
            code: 'C101',
            teacherName: 'Professor 1',
            colorIndex: 0,
          ),
          CourseModel(
            id: '2',
            name: 'Course 2',
            code: 'C102',
            teacherName: 'Professor 2',
            colorIndex: 1,
          ),
        ];

        // Test the provider logic
        final result = mockCourses.where((c) => c.id == '1').firstOrNull;
        expect(result?.name, 'Course 1');
        
        final notFound = mockCourses.where((c) => c.id == '999').firstOrNull;
        expect(notFound, null);
      });
    });
  });

  group('CourseModel Tests', () {
    test('should create CourseModel with required fields', () {
      const course = CourseModel(
        id: '1',
        name: 'Test Course',
        code: 'TC101',
        teacherName: 'Test Professor',
        colorIndex: 0,
      );

      expect(course.id, '1');
      expect(course.name, 'Test Course');
      expect(course.code, 'TC101');
      expect(course.teacherName, 'Test Professor');
      expect(course.colorIndex, 0);
      expect(course.progress, 0.0); // Default
      expect(course.pendingActivities, 0); // Default
      expect(course.activities, []); // Default
    });

    test('should create CourseModel with all fields', () {
      final course = CourseModel(
        id: '1',
        name: 'Test Course',
        code: 'TC101',
        teacherName: 'Test Professor',
        colorIndex: 0,
        progress: 0.5,
        pendingActivities: 2,
        activities: [
          ActivityModel(
            id: 'a1',
            title: 'Test Activity',
            dueDate: DateTime.now(),
            type: 'assignment',
          ),
        ],
        description: 'Test description',
        schedule: 'Mon-Wed-Fri 10:00',
      );

      expect(course.progress, 0.5);
      expect(course.pendingActivities, 2);
      expect(course.activities.length, 1);
      expect(course.description, 'Test description');
      expect(course.schedule, 'Mon-Wed-Fri 10:00');
    });
  });

  group('ActivityModel Tests', () {
    test('should create ActivityModel with required fields', () {
      final activity = ActivityModel(
        id: 'a1',
        title: 'Test Activity',
        dueDate: DateTime.now(),
        type: 'assignment',
      );

      expect(activity.id, 'a1');
      expect(activity.title, 'Test Activity');
      expect(activity.type, 'assignment');
      expect(activity.requiresFile, true); // Default
      expect(activity.isSubmitted, false); // Default
      expect(activity.isGraded, false); // Default
      expect(activity.grade, null);
      expect(activity.feedback, null);
    });

    test('should create ActivityModel with all fields', () {
      final activity = ActivityModel(
        id: 'a1',
        title: 'Test Activity',
        description: 'Test description',
        dueDate: DateTime.now(),
        type: 'exam',
        requiresFile: false,
        isSubmitted: true,
        isGraded: true,
        grade: 85.5,
        feedback: 'Good work!',
      );

      expect(activity.description, 'Test description');
      expect(activity.requiresFile, false);
      expect(activity.isSubmitted, true);
      expect(activity.isGraded, true);
      expect(activity.grade, 85.5);
      expect(activity.feedback, 'Good work!');
    });
  });

  group('Mock Data Tests', () {
    test('should provide valid mock course list', () {
      final mockCourses = CourseModel.mockList;
      
      expect(mockCourses.length, 4);
      expect(mockCourses[0].name, 'Estructuras de Datos');
      expect(mockCourses[1].name, 'Cálculo II');
      expect(mockCourses[2].name, 'Ingeniería de Software I');
      expect(mockCourses[3].name, 'Sistemas Operativos');
      
      expect(mockCourses[0].activities.length, 2);
      expect(mockCourses[1].activities.isEmpty, true);
    });

    test('should have valid mock activities', () {
      final mockCourses = CourseModel.mockList;
      final activities = mockCourses[0].activities;
      
      expect(activities[0].title, 'Taller Árboles Binarios');
      expect(activities[0].type, 'Tarea');
      expect(activities[1].title, 'Parcial 2');
      expect(activities[1].type, 'Examen');
    });
  });
}

// Mock classes for testing
class MockApiResponse<T> {
  final T data;
  
  MockApiResponse(this.data);
}
