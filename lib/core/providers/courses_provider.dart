import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';
import '../../models/course.dart';

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
  }
}

final coursesServiceProvider = Provider<CoursesService>(
  (ref) => CoursesService(),
);

final coursesProvider = FutureProvider.autoDispose<List<CourseModel>>((ref) {
  return ref.read(coursesServiceProvider).fetchAll();
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
