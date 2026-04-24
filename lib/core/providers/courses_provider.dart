import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import 'auth_provider.dart';
import '../../models/course.dart';

const _courseColors = [0, 1, 2, 3, 4, 5];

class CoursesService {
  Future<List<CourseModel>> fetchAll(String role) async {
    final endpoint =
        role == 'teacher' ? '/courses/teacher' : '/courses/student';
    final res = await ApiClient.instance.get<dynamic>(endpoint);

    final raw = res.data is List
        ? res.data as List
        : (res.data is Map ? (res.data['data'] as List? ?? []) : []);

    return raw.asMap().entries.map((entry) {
      final i = entry.key;
      final c = entry.value as Map<String, dynamic>;
      return CourseModel(
        id: c['id']?.toString() ?? '',
        name: c['title']?.toString() ?? c['name']?.toString() ?? '',
        code: c['invite_code']?.toString() ?? c['code']?.toString() ?? '',
        teacherName:
            c['professor']?.toString() ?? c['teacherName']?.toString() ?? '',
        colorIndex: _courseColors[i % _courseColors.length],
        progress: (c['progress'] as num?)?.toDouble() ?? 0.0,
        pendingActivities:
            (c['pendingTasks'] as int?) ?? (c['pendingActivities'] as int?) ?? 0,
        description: c['description']?.toString(),
      );
    }).toList();
  }
}

final coursesServiceProvider =
    Provider<CoursesService>((_) => CoursesService());

final coursesProvider = FutureProvider.autoDispose<List<CourseModel>>((ref) {
  final role = ref.watch(userRoleProvider);
  return ref.read(coursesServiceProvider).fetchAll(role);
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
