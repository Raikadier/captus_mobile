import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/course.dart';

<<<<<<< Updated upstream
class CoursesService {
  Future<List<CourseModel>> fetchAll() async {
    final courses = LocalStorageService.courses;
    return courses
        .map((c) => CourseModel(
              id: c['id']?.toString() ?? '',
              name: c['name']?.toString() ?? '',
              code: c['code']?.toString() ?? '',
              teacherName: c['teacherName']?.toString() ?? '',
              colorIndex: c['colorIndex'] as int? ?? 0,
              progress: (c['progress'] as num?)?.toDouble() ?? 0.0,
              pendingActivities: c['pendingActivities'] as int? ?? 0,
              description: c['description']?.toString(),
              schedule: c['schedule']?.toString(),
            ))
        .toList();
=======
const _courseColors = [0, 1, 2, 3, 4, 5];

import '../database/database_service.dart';

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
>>>>>>> Stashed changes
  }
}

final coursesServiceProvider = Provider<CoursesService>(
  (ref) => CoursesService(),
);

final coursesProvider = FutureProvider.autoDispose<List<CourseModel>>((ref) {
<<<<<<< Updated upstream
  return ref.read(coursesServiceProvider).fetchAll();
=======
  final role = ref.watch(userRoleProvider);
  final user = ref.watch(currentUserProvider);
  return ref.read(coursesServiceProvider).fetchAll(role, user?.id ?? '');
>>>>>>> Stashed changes
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
