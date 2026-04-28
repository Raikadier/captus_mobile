import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/course.dart';
import '../database/database_service.dart';
import 'auth_provider.dart';

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
