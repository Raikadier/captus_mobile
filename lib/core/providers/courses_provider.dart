import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../models/course.dart';
import '../services/api_client.dart';
import 'auth_provider.dart';

// ─── TeacherCourse (lightweight view model for teacher list) ─────────────────

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

// ─── Provider: list of courses for the current user ──────────────────────────

/// Fetches courses from the Express API.
///
/// Teachers → GET /courses/teacher
/// Students → GET /courses/student
///
/// Falls back to an empty list on error so the UI shows EmptyState rather
/// than a crash.
final coursesProvider = FutureProvider.autoDispose<List<CourseModel>>((ref) async {
  final role = ref.watch(userRoleProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final endpoint = role == 'teacher' ? '/courses/teacher' : '/courses/student';

  try {
    final res = await ApiClient.instance.get<dynamic>(endpoint);
    final raw = res.data;
    if (raw is! List) return [];
    return raw
        .asMap()
        .entries
        .map((e) =>
            CourseModel.fromApiJson(e.value as Map<String, dynamic>,
                colorSeed: e.key))
        .toList();
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  }
});

// ─── Provider: single course by id (derived from coursesProvider) ─────────────

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

// ─── TeacherCoursesProvider (re-shape for teacher-only views) ────────────────

final teacherCoursesProvider =
    FutureProvider.autoDispose<List<TeacherCourse>>((ref) async {
  final courses = await ref.watch(coursesProvider.future);
  return courses.map((c) {
    return TeacherCourse(
      id: c.id,
      title: c.name,
      code: c.code,
      studentCount: 0, // populated when we have a student-count endpoint
      inviteCode: c.code,
      colorIndex: c.colorIndex,
    );
  }).toList();
});

// ─── TeacherCoursesNotifier (create / invalidate) ────────────────────────────

class TeacherCoursesNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createCourse({
    required String title,
    String? description,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await ApiClient.instance.post('/courses', data: {
        'title': title,
        'description': description ?? '',
      });
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }

    ref.invalidate(coursesProvider);
    ref.invalidate(teacherCoursesProvider);
  }
}

final teacherCoursesNotifierProvider =
    AsyncNotifierProvider<TeacherCoursesNotifier, void>(
        TeacherCoursesNotifier.new);
