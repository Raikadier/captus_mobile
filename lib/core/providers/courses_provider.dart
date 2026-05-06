import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/course.dart';
import '../database/database_service.dart';
import 'auth_provider.dart';

class TeacherCourse {
  final String id;
  final String title;
  final String code;
  final int studentCount;
  final String inviteCode;
  final int colorIndex;

  TeacherCourse({
    required this.id,
    required this.title,
    required this.code,
    required this.studentCount,
    required this.inviteCode,
    required this.colorIndex,
  });
}

class CoursesService {
  Future<List<CourseModel>> fetchAll(String role, String userId) async {
    final raw = await DatabaseService.query(
      'courses',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return raw.map((c) => CourseModel.fromJson(c)).toList();
  }

  Future<void> create(Map<String, dynamic> data) async {
    await DatabaseService.insert('courses', data);
  }
}

final coursesServiceProvider = Provider<CoursesService>(
  (ref) => CoursesService(),
);

final coursesProvider = FutureProvider.autoDispose<List<CourseModel>>((ref) {
  final role = ref.watch(userRoleProvider);
  final user = ref.watch(currentUserProvider);
  return ref.read(coursesServiceProvider).fetchAll(role, user?.id ?? '');
});

final courseByIdProvider =
    Provider.family<AsyncValue<CourseModel?>, String>((ref, id) {
  return ref.watch(coursesProvider).whenData(
    (courses) {
      try {
        return courses.firstWhere((c) => c.id == id);
      } catch (_) {
        return null;
      }
    },
  );
});

final teacherCoursesProvider =
    FutureProvider.autoDispose<List<TeacherCourse>>((ref) async {
  final courses = await ref.watch(coursesProvider.future);
  return courses.map((c) {
    return TeacherCourse(
      id: c.id,
      title: c.name,
      code: c.code,
      studentCount: 0, // Fallback safe
      inviteCode: c.code,
      colorIndex: c.colorIndex,
    );
  }).toList();
});

class TeacherCoursesNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createCourse({
    required String title,
    String? description,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await ref.read(coursesServiceProvider).create({
      'name': title,
      'description': description ?? '',
      'userId': user.id,
      'code': title.length >= 3
          ? title.substring(0, 3).toUpperCase()
          : title.toUpperCase(),
      'colorIndex': 0,
      'teacherName': user.name,
    });

    ref.invalidate(coursesProvider);
    ref.invalidate(teacherCoursesProvider);
  }
}

final teacherCoursesNotifierProvider =
    AsyncNotifierProvider<TeacherCoursesNotifier, void>(
        TeacherCoursesNotifier.new);
