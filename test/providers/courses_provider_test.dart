// ignore_for_file: subtype_of_sealed_class

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:captus_mobile/core/providers/courses_provider.dart';
import 'package:captus_mobile/models/course.dart';

void main() {
  group('CourseModel', () {
    test('should create from API JSON (student shape)', () {
      final json = {
        'id': '1',
        'title': 'Estructuras de Datos',
        'invite_code': 'IS-301',
        'professor': 'Prof. García',
        'progress': 0.75,
        'pendingActivities': 3,
        'description': 'Curso de algoritmos.',
      };

      final course = CourseModel.fromApiJson(json);

      expect(course.id, '1');
      expect(course.name, 'Estructuras de Datos');
      expect(course.code, 'IS-301');
      expect(course.teacherName, 'Prof. García');
      expect(course.progress, 0.75);
      expect(course.pendingActivities, 3);
      expect(course.description, 'Curso de algoritmos.');
    });

    test('should create from API JSON (teacher shape)', () {
      final json = {
        'id': 't1',
        'title': 'Álgebra',
        'invite_code': 'MA-101',
        'pendingTasks': 5,
      };

      final course = CourseModel.fromApiJson(json, colorSeed: 2);

      expect(course.id, 't1');
      expect(course.name, 'Álgebra');
      expect(course.code, 'MA-101');
      expect(course.teacherName, '');
      expect(course.pendingActivities, 5);
      expect(course.progress, 0.0);
    });

    test('fromApiJson should handle activities', () {
      final json = {
        'id': 'c1',
        'title': 'Course',
        'activities': [
          {'id': 'a1', 'title': 'Act 1', 'dueDate': '2026-06-01T00:00:00.000', 'type': 'Tarea'},
        ],
      };

      final course = CourseModel.fromApiJson(json);

      expect(course.activities, hasLength(1));
      expect(course.activities.first.title, 'Act 1');
    });

    test('fromApiJson should generate stable colorIndex from id', () {
      final json = {'id': 'test-id-123', 'title': 'Course'};
      final course = CourseModel.fromApiJson(json);

      expect(course.colorIndex, inInclusiveRange(0, 5));
    });

    test('toJson should serialize correctly', () {
      final course = CourseModel(
        id: 'c1',
        name: 'Test',
        code: 'TST-101',
        teacherName: 'Teacher',
        colorIndex: 1,
        progress: 0.5,
        pendingActivities: 2,
      );

      final json = course.toJson();

      expect(json['id'], 'c1');
      expect(json['name'], 'Test');
      expect(json['code'], 'TST-101');
      expect(json['teacherName'], 'Teacher');
      expect(json['colorIndex'], 1);
      expect(json['progress'], 0.5);
      expect(json['pendingActivities'], 2);
    });

    test('fromJson should handle missing fields', () {
      final json = {'id': 'c1'};
      final course = CourseModel.fromJson(json);

      expect(course.id, 'c1');
      expect(course.name, '');
      expect(course.code, '');
      expect(course.teacherName, '');
      expect(course.progress, 0.0);
    });
  });

  group('TeacherCourse', () {
    test('should create TeacherCourse with required fields', () {
      final tc = TeacherCourse(
        id: 't1',
        title: 'Álgebra',
        code: 'MA-101',
        studentCount: 25,
        inviteCode: 'INV-123',
        colorIndex: 0,
      );

      expect(tc.id, 't1');
      expect(tc.title, 'Álgebra');
      expect(tc.code, 'MA-101');
      expect(tc.studentCount, 25);
      expect(tc.inviteCode, 'INV-123');
      expect(tc.colorIndex, 0);
    });
  });

  group('coursesProvider', () {
    test('should return empty list when user is null', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final courses = await container.read(coursesProvider.future);

      expect(courses, isEmpty);
    });
  });

  group('courseByIdProvider', () {
    test('should return AsyncLoading for any id', () {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final result = container.read(courseByIdProvider('nonexistent'));

      expect(result, isA<AsyncLoading<CourseModel?>>());
    });
  });
}
