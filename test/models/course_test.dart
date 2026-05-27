import 'package:flutter_test/flutter_test.dart';
import 'package:captus_mobile/models/course.dart';

void main() {
  group('CourseModel', () {
    test('should create CourseModel with required fields', () {
      final course = CourseModel(
        id: 'c1',
        name: 'Estructuras de Datos',
        code: 'IS-301',
        teacherName: 'Prof. García',
        colorIndex: 0,
      );

      expect(course.id, 'c1');
      expect(course.name, 'Estructuras de Datos');
      expect(course.code, 'IS-301');
      expect(course.teacherName, 'Prof. García');
      expect(course.colorIndex, 0);
      expect(course.progress, 0.0);
      expect(course.pendingActivities, 0);
      expect(course.activities, isEmpty);
    });

    test('should create CourseModel with all fields', () {
      final course = CourseModel(
        id: 'c1',
        name: 'Estructuras de Datos',
        code: 'IS-301',
        teacherName: 'Prof. García',
        colorIndex: 2,
        progress: 0.75,
        pendingActivities: 3,
        activities: [
          ActivityModel(
            id: 'a1',
            title: 'Taller',
            dueDate: DateTime(2026, 6, 1),
            type: 'Tarea',
          ),
        ],
        description: 'Curso de algoritmos.',
        schedule: 'Lun/Mié 10:00',
      );

      expect(course.progress, 0.75);
      expect(course.pendingActivities, 3);
      expect(course.activities, hasLength(1));
      expect(course.description, 'Curso de algoritmos.');
      expect(course.schedule, 'Lun/Mié 10:00');
    });

    test('should convert to JSON and back', () {
      final course = CourseModel(
        id: 'c1',
        name: 'Estructuras de Datos',
        code: 'IS-301',
        teacherName: 'Prof. García',
        colorIndex: 0,
        progress: 0.65,
        pendingActivities: 2,
        description: 'Algoritmos.',
        schedule: 'Lun/Mié 10:00',
      );

      final json = course.toJson();
      final restored = CourseModel.fromJson(json);

      expect(restored.id, course.id);
      expect(restored.name, course.name);
      expect(restored.code, course.code);
      expect(restored.teacherName, course.teacherName);
      expect(restored.colorIndex, course.colorIndex);
      expect(restored.progress, course.progress);
      expect(restored.pendingActivities, course.pendingActivities);
      expect(restored.description, course.description);
      expect(restored.schedule, course.schedule);
    });

    test('fromJson should handle missing fields', () {
      final json = {'id': 'c1', 'name': 'Course'};
      final course = CourseModel.fromJson(json);

      expect(course.id, 'c1');
      expect(course.name, 'Course');
      expect(course.code, '');
      expect(course.teacherName, '');
      expect(course.colorIndex, 0);
      expect(course.progress, 0.0);
    });

    test('fromApiJson should map student shape', () {
      final json = {
        'id': 1,
        'title': 'Estructuras de Datos',
        'invite_code': 'IS-301',
        'professor': 'Prof. García',
        'progress': 0.65,
        'pendingActivities': 2,
      };

      final course = CourseModel.fromApiJson(json);

      expect(course.id, '1');
      expect(course.name, 'Estructuras de Datos');
      expect(course.code, 'IS-301');
      expect(course.teacherName, 'Prof. García');
      expect(course.progress, 0.65);
    });

    test('fromApiJson should map teacher shape', () {
      final json = {
        'id': 't1',
        'title': 'Álgebra Lineal',
        'invite_code': 'MA-101',
        'pendingTasks': 5,
        'description': 'Curso de álgebra.',
      };

      final course = CourseModel.fromApiJson(json, colorSeed: 3);

      expect(course.id, 't1');
      expect(course.name, 'Álgebra Lineal');
      expect(course.code, 'MA-101');
      expect(course.teacherName, '');
      expect(course.pendingActivities, 5);
      expect(course.description, 'Curso de álgebra.');
    });

    test('fromApiJson should generate color from id hash', () {
      final json1 = {'id': 'aaa', 'title': 'Course A'};
      final json2 = {'id': 'bbb', 'title': 'Course B'};

      final course1 = CourseModel.fromApiJson(json1);
      final course2 = CourseModel.fromApiJson(json2);

      expect(course1.colorIndex, inInclusiveRange(0, 5));
      expect(course2.colorIndex, inInclusiveRange(0, 5));
    });

    test('fromApiJson should handle activities list', () {
      final json = {
        'id': 'c1',
        'title': 'Course',
        'activities': [
          {'id': 'a1', 'title': 'Activity 1', 'dueDate': '2026-06-01T00:00:00.000', 'type': 'Tarea'},
        ],
      };

      final course = CourseModel.fromApiJson(json);

      expect(course.activities, hasLength(1));
      expect(course.activities.first.title, 'Activity 1');
    });

    test('mockList should return predefined courses', () {
      final courses = CourseModel.mockList;

      expect(courses, hasLength(4));
      expect(courses[0].name, 'Estructuras de Datos');
      expect(courses[1].name, 'Cálculo II');
      expect(courses[2].name, 'Ingeniería de Software I');
      expect(courses[3].name, 'Sistemas Operativos');
    });
  });

  group('ActivityModel', () {
    test('should create ActivityModel with required fields', () {
      final dueDate = DateTime(2026, 6, 1);
      final activity = ActivityModel(
        id: 'a1',
        title: 'Taller',
        dueDate: dueDate,
        type: 'Tarea',
      );

      expect(activity.id, 'a1');
      expect(activity.title, 'Taller');
      expect(activity.dueDate, dueDate);
      expect(activity.type, 'Tarea');
      expect(activity.requiresFile, true);
      expect(activity.isSubmitted, false);
    });

    test('should convert to JSON and back', () {
      final dueDate = DateTime(2026, 6, 1);
      final activity = ActivityModel(
        id: 'a1',
        title: 'Taller',
        dueDate: dueDate,
        type: 'Examen',
        requiresFile: false,
        isSubmitted: true,
        grade: 4.5,
        feedback: 'Bien hecho',
      );

      final json = activity.toJson();
      final restored = ActivityModel.fromJson(json);

      expect(restored.id, activity.id);
      expect(restored.title, activity.title);
      expect(restored.dueDate.toIso8601String(), dueDate.toIso8601String());
      expect(restored.type, activity.type);
      expect(restored.requiresFile, activity.requiresFile);
      expect(restored.isSubmitted, activity.isSubmitted);
      expect(restored.grade, activity.grade);
      expect(restored.feedback, activity.feedback);
    });
  });
}
