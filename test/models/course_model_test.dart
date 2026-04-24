import 'package:flutter_test/flutter_test.dart';
import 'package:captus_mobile/models/course.dart';

void main() {
  group('CourseModel Tests', () {
    test('should create CourseModel with required fields', () {
      // Arrange & Act
      const course = CourseModel(
        id: '1',
        name: 'Test Course',
        code: 'TC101',
        teacherName: 'Test Teacher',
        colorIndex: 0,
      );

      // Assert
      expect(course.id, '1');
      expect(course.name, 'Test Course');
      expect(course.code, 'TC101');
      expect(course.teacherName, 'Test Teacher');
      expect(course.colorIndex, 0);
      expect(course.progress, 0.0); // Default value
      expect(course.pendingActivities, 0); // Default value
      expect(course.activities, []); // Default value
      expect(course.description, null);
      expect(course.schedule, null);
    });

    test('should create CourseModel with all fields', () {
      // Arrange & Act
      final course = CourseModel(
        id: '1',
        name: 'Test Course',
        code: 'TC101',
        teacherName: 'Test Teacher',
        colorIndex: 0,
        progress: 0.75,
        pendingActivities: 3,
        activities: [
          ActivityModel(
            id: 'a1',
            title: 'Test Activity',
            dueDate: DateTime.now(),
            type: 'assignment',
          ),
        ],
        description: 'Course description',
        schedule: 'Mon-Wed-Fri 10:00',
      );

      // Assert
      expect(course.progress, 0.75);
      expect(course.pendingActivities, 3);
      expect(course.activities.length, 1);
      expect(course.activities[0].title, 'Test Activity');
      expect(course.description, 'Course description');
      expect(course.schedule, 'Mon-Wed-Fri 10:00');
    });

    test('should handle empty activities list', () {
      // Arrange & Act
      const course = CourseModel(
        id: '1',
        name: 'Test Course',
        code: 'TC101',
        teacherName: 'Test Teacher',
        colorIndex: 0,
      );

      // Assert
      expect(course.activities, []);
      expect(course.activities.isEmpty, true);
    });

    test('should handle null description and schedule', () {
      // Arrange & Act
      const course = CourseModel(
        id: '1',
        name: 'Test Course',
        code: 'TC101',
        teacherName: 'Test Teacher',
        colorIndex: 0,
      );

      // Assert
      expect(course.description, null);
      expect(course.schedule, null);
    });

    test('should provide valid mock course list', () {
      // Act
      final mockCourses = CourseModel.mockList;

      // Assert
      expect(mockCourses.length, 4);
      expect(mockCourses[0].name, 'Estructuras de Datos');
      expect(mockCourses[1].name, 'Cálculo II');
      expect(mockCourses[2].name, 'Ingeniería de Software I');
      expect(mockCourses[3].name, 'Sistemas Operativos');

      // Verify course codes
      expect(mockCourses[0].code, 'IS-301');
      expect(mockCourses[1].code, 'MA-201');
      expect(mockCourses[2].code, 'IS-401');
      expect(mockCourses[3].code, 'IS-302');

      // Verify teacher names
      expect(mockCourses[0].teacherName, 'Prof. García');
      expect(mockCourses[1].teacherName, 'Prof. Martínez');
      expect(mockCourses[2].teacherName, 'Prof. López');
      expect(mockCourses[3].teacherName, 'Prof. Rodríguez');

      // Verify color indices are sequential
      expect(mockCourses[0].colorIndex, 0);
      expect(mockCourses[1].colorIndex, 1);
      expect(mockCourses[2].colorIndex, 2);
      expect(mockCourses[3].colorIndex, 3);

      // Verify progress values
      expect(mockCourses[0].progress, 0.65);
      expect(mockCourses[1].progress, 0.40);
      expect(mockCourses[2].progress, 0.80);
      expect(mockCourses[3].progress, 0.55);

      // Verify pending activities
      expect(mockCourses[0].pendingActivities, 2);
      expect(mockCourses[1].pendingActivities, 1);
      expect(mockCourses[2].pendingActivities, 3);
      expect(mockCourses[3].pendingActivities, 0);
    });

    test('should provide valid mock activities', () {
      // Arrange
      final mockCourses = CourseModel.mockList;
      final activities = mockCourses[0].activities;

      // Assert
      expect(activities.length, 2);
      expect(activities[0].title, 'Taller Árboles Binarios');
      expect(activities[0].type, 'Tarea');
      expect(activities[0].isSubmitted, false);
      expect(activities[1].title, 'Parcial 2');
      expect(activities[1].type, 'Examen');
      expect(activities[1].isSubmitted, false);

      // Verify due dates are in the future
      expect(activities[0].dueDate.isAfter(DateTime.now()), true);
      expect(activities[1].dueDate.isAfter(DateTime.now()), true);
    });

    test('should handle course with no activities', () {
      // Arrange
      final mockCourses = CourseModel.mockList;
      final courseWithNoActivities = mockCourses[1]; // Cálculo II

      // Assert
      expect(courseWithNoActivities.activities, []);
      expect(courseWithNoActivities.activities.isEmpty, true);
    });
  });

  group('ActivityModel Tests', () {
    test('should create ActivityModel with required fields', () {
      // Arrange & Act
      final activity = ActivityModel(
        id: 'a1',
        title: 'Test Activity',
        dueDate: DateTime.now(),
        type: 'assignment',
      );

      // Assert
      expect(activity.id, 'a1');
      expect(activity.title, 'Test Activity');
      expect(activity.type, 'assignment');
      expect(activity.dueDate, isA<DateTime>());
      expect(activity.requiresFile, true); // Default value
      expect(activity.isSubmitted, false); // Default value
      expect(activity.isGraded, false); // Default value
      expect(activity.grade, null);
      expect(activity.feedback, null);
    });

    test('should create ActivityModel with all fields', () {
      // Arrange
      final dueDate = DateTime(2024, 12, 25);
      
      // Act
      final activity = ActivityModel(
        id: 'a1',
        title: 'Complete Assignment',
        description: 'Complete the programming assignment',
        dueDate: dueDate,
        type: 'homework',
        requiresFile: false,
        isSubmitted: true,
        isGraded: true,
        grade: 85.5,
        feedback: 'Good work!',
      );

      // Assert
      expect(activity.description, 'Complete the programming assignment');
      expect(activity.requiresFile, false);
      expect(activity.isSubmitted, true);
      expect(activity.isGraded, true);
      expect(activity.grade, 85.5);
      expect(activity.feedback, 'Good work!');
    });

    test('should handle null grade and feedback', () {
      // Arrange & Act
      final activity = ActivityModel(
        id: 'a1',
        title: 'Test Activity',
        dueDate: DateTime.now(),
        type: 'quiz',
      );

      // Assert
      expect(activity.grade, null);
      expect(activity.feedback, null);
      expect(activity.isGraded, false);
    });

    test('should handle different activity types', () {
      final types = ['Tarea', 'Examen', 'Quiz', 'Proyecto', 'Laboratorio'];
      
      for (final type in types) {
        final activity = ActivityModel(
          id: 'a_${type}',
          title: 'Test $type',
          dueDate: DateTime.now(),
          type: type,
        );
        
        expect(activity.type, type);
      }
    });

    test('should handle submitted and graded activities', () {
      // Arrange & Act
      final submittedActivity = ActivityModel(
        id: 'a1',
        title: 'Submitted Activity',
        dueDate: DateTime.now(),
        type: 'assignment',
        isSubmitted: true,
        isGraded: true,
        grade: 90.0,
      );

      // Assert
      expect(submittedActivity.isSubmitted, true);
      expect(submittedActivity.isGraded, true);
      expect(submittedActivity.grade, 90.0);

      // Arrange & Act
      final unsubmittedActivity = ActivityModel(
        id: 'a2',
        title: 'Unsubmitted Activity',
        dueDate: DateTime.now(),
        type: 'assignment',
      );

      // Assert
      expect(unsubmittedActivity.isSubmitted, false);
      expect(unsubmittedActivity.isGraded, false);
      expect(unsubmittedActivity.grade, null);
    });

    test('should handle file requirement', () {
      // Arrange & Act
      final fileRequired = ActivityModel(
        id: 'a1',
        title: 'File Required',
        dueDate: DateTime.now(),
        type: 'assignment',
        requiresFile: true,
      );

      final fileNotRequired = ActivityModel(
        id: 'a2',
        title: 'No File Required',
        dueDate: DateTime.now(),
        type: 'quiz',
        requiresFile: false,
      );

      // Assert
      expect(fileRequired.requiresFile, true);
      expect(fileNotRequired.requiresFile, false);
    });

    test('should handle due dates correctly', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final futureDate = DateTime.now().add(const Duration(days: 1));
      final today = DateTime.now();

      final pastActivity = ActivityModel(
        id: 'a1',
        title: 'Past Activity',
        dueDate: pastDate,
        type: 'assignment',
      );

      final futureActivity = ActivityModel(
        id: 'a2',
        title: 'Future Activity',
        dueDate: futureDate,
        type: 'assignment',
      );

      final todayActivity = ActivityModel(
        id: 'a3',
        title: 'Today Activity',
        dueDate: today,
        type: 'assignment',
      );

      expect(pastActivity.dueDate.isBefore(DateTime.now()), true);
      expect(futureActivity.dueDate.isAfter(DateTime.now()), true);
      expect(todayActivity.dueDate.isAtSameMomentAs(today), true);
    });
  });

  group('CourseModel Integration Tests', () {
    test('should handle course with multiple activities', () {
      // Arrange & Act
      final course = CourseModel(
        id: '1',
        name: 'Course with Activities',
        code: 'C101',
        teacherName: 'Teacher',
        colorIndex: 0,
        activities: [
          ActivityModel(
            id: 'a1',
            title: 'Activity 1',
            dueDate: DateTime.now(),
            type: 'assignment',
            isSubmitted: true,
            isGraded: true,
            grade: 85.0,
          ),
          ActivityModel(
            id: 'a2',
            title: 'Activity 2',
            dueDate: DateTime.now().add(const Duration(days: 1)),
            type: 'quiz',
            isSubmitted: false,
          ),
          ActivityModel(
            id: 'a3',
            title: 'Activity 3',
            dueDate: DateTime.now().add(const Duration(days: 2)),
            type: 'project',
            isSubmitted: false,
          ),
        ],
      );

      // Assert
      expect(course.activities.length, 3);
      expect(course.activities[0].isSubmitted, true);
      expect(course.activities[1].isSubmitted, false);
      expect(course.activities[2].isSubmitted, false);
      
      // Count submitted activities
      final submittedCount = course.activities.where((a) => a.isSubmitted).length;
      expect(submittedCount, 1);
      
      // Count graded activities
      final gradedCount = course.activities.where((a) => a.isGraded).length;
      expect(gradedCount, 1);
    });

    test('should calculate pending activities correctly', () {
      // Arrange & Act
      final course = CourseModel(
        id: '1',
        name: 'Test Course',
        code: 'TC101',
        teacherName: 'Teacher',
        colorIndex: 0,
        pendingActivities: 2,
        activities: [
          ActivityModel(
            id: 'a1',
            title: 'Pending 1',
            dueDate: DateTime.now().add(const Duration(days: 1)),
            type: 'assignment',
            isSubmitted: false,
          ),
          ActivityModel(
            id: 'a2',
            title: 'Pending 2',
            dueDate: DateTime.now().add(const Duration(days: 2)),
            type: 'quiz',
            isSubmitted: false,
          ),
        ],
      );

      // Assert
      expect(course.pendingActivities, 2);
      
      // Verify actual pending activities match the count
      final actualPending = course.activities.where((a) => !a.isSubmitted).length;
      expect(actualPending, 2);
    });
  });

  group('ActivityModel Edge Cases', () {
    test('should handle empty title', () {
      final activity = ActivityModel(
        id: 'a1',
        title: '',
        dueDate: DateTime.now(),
        type: 'assignment',
      );
      
      expect(activity.title, '');
    });

    test('should handle very long title', () {
      final longTitle = 'A' * 200;
      final activity = ActivityModel(
        id: 'a1',
        title: longTitle,
        dueDate: DateTime.now(),
        type: 'assignment',
      );
      
      expect(activity.title.length, 200);
    });

    test('should handle edge case due dates', () {
      final farFuture = DateTime.now().add(const Duration(days: 365));
      final farPast = DateTime.now().subtract(const Duration(days: 365));
      
      final futureActivity = ActivityModel(
        id: 'a1',
        title: 'Future Activity',
        dueDate: farFuture,
        type: 'assignment',
      );
      
      final pastActivity = ActivityModel(
        id: 'a2',
        title: 'Past Activity',
        dueDate: farPast,
        type: 'assignment',
      );
      
      expect(futureActivity.dueDate.isAfter(DateTime.now()), true);
      expect(pastActivity.dueDate.isBefore(DateTime.now()), true);
    });

    test('should handle extreme grade values', () {
      final perfectScore = ActivityModel(
        id: 'a1',
        title: 'Perfect Score',
        dueDate: DateTime.now(),
        type: 'assignment',
        isSubmitted: true,
        isGraded: true,
        grade: 100.0,
      );
      
      final zeroScore = ActivityModel(
        id: 'a2',
        title: 'Zero Score',
        dueDate: DateTime.now(),
        type: 'assignment',
        isSubmitted: true,
        isGraded: true,
        grade: 0.0,
      );
      
      expect(perfectScore.grade, 100.0);
      expect(zeroScore.grade, 0.0);
    });
  });
}
