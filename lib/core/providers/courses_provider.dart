import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

final _supabase = Supabase.instance.client;
final _random = Random.secure();

// ── Modelo liviano para cursos del docente ────────────────────────────────────
class TeacherCourse {
  final int id;
  final String title;
  final String inviteCode;
  final String? description;
  final int studentCount;
  final int colorIndex;
  final DateTime createdAt;

  const TeacherCourse({
    required this.id,
    required this.title,
    required this.inviteCode,
    this.description,
    required this.studentCount,
    required this.colorIndex,
    required this.createdAt,
  });

  factory TeacherCourse.fromJson(Map<String, dynamic> json) {
    // FIX Bug 2 & 3: colorIndex basado en el id del curso (estable),
    // no en la posición de la lista (cambia según cuántos cursos haya).
    final id = json['id'] as int;
    final enrollments = json['course_enrollments'] as List? ?? [];
    return TeacherCourse(
      id: id,
      title: json['title']?.toString() ?? '',
      inviteCode: json['invite_code']?.toString() ?? '',
      description: json['description']?.toString(),
      studentCount: enrollments.length,
      colorIndex: id % 10, // 10 colores disponibles en AppColors.courseColors
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

// ── Provider de cursos del docente ────────────────────────────────────────────
final teacherCoursesProvider =
    FutureProvider.autoDispose<List<TeacherCourse>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final res = await _supabase
      .from('courses')
      .select('*, course_enrollments(id)')
      .eq('teacher_id', user.id)
      .order('created_at', ascending: false);

  final list = res as List;
  return list
      .map((e) => TeacherCourse.fromJson(e as Map<String, dynamic>))
      .toList();
});

// ── Crear curso ───────────────────────────────────────────────────────────────
class TeacherCoursesNotifier extends AsyncNotifier<List<TeacherCourse>> {
  @override
  Future<List<TeacherCourse>> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return [];

    final res = await _supabase
        .from('courses')
        .select('*, course_enrollments(id)')
        .eq('teacher_id', user.id)
        .order('created_at', ascending: false);

    final list = res as List;
    return list
        .map((e) => TeacherCourse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TeacherCourse?> createCourse({
    required String title,
    required String description,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return null;

    final inviteCode = _generateCode();

    final res = await _supabase
        .from('courses')
        .insert({
          'teacher_id': user.id,
          'title': title,
          'description': description,
          'invite_code': inviteCode,
        })
        .select('*, course_enrollments(id)')
        .single();

    final newCourse = TeacherCourse.fromJson(res as Map<String, dynamic>);

    state = AsyncData([newCourse, ...?state.value]);
    ref.invalidate(teacherCoursesProvider);
    return newCourse;
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (_) => chars[_random.nextInt(chars.length)]).join();
  }
}

final teacherCoursesNotifierProvider =
    AsyncNotifierProvider<TeacherCoursesNotifier, List<TeacherCourse>>(
        TeacherCoursesNotifier.new);

// ── Modelo de estudiante inscrito ─────────────────────────────────────────────
class EnrolledStudent {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime enrolledAt;

  const EnrolledStudent({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.enrolledAt,
  });

  factory EnrolledStudent.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>? ?? {};
    return EnrolledStudent(
      id: profile['id']?.toString() ?? '',
      name: profile['name']?.toString() ?? 'Sin nombre',
      email: profile['email']?.toString() ?? '',
      avatarUrl: profile['avatar_url']?.toString(),
      enrolledAt: DateTime.tryParse(json['enrolled_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

// ── Provider de estudiantes de un curso ───────────────────────────────────────
final courseStudentsProvider = FutureProvider.autoDispose
    .family<List<EnrolledStudent>, int>((ref, courseId) async {
  final res = await _supabase
      .from('course_enrollments')
      .select('enrolled_at, profiles:user_id(id, name, email, avatar_url)')
      .eq('course_id', courseId);

  final list = res as List;
  return list
      .map((e) => EnrolledStudent.fromJson(e as Map<String, dynamic>))
      .toList();
});

// ── Provider de un curso individual ───────────────────────────────────────────
final teacherCourseDetailProvider = FutureProvider.autoDispose
    .family<TeacherCourse?, int>((ref, courseId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final res = await _supabase
      .from('courses')
      .select('*, course_enrollments(id)')
      .eq('id', courseId)
      .eq('teacher_id', user.id)
      .maybeSingle();

  if (res == null) return null;

  // FIX Bug 2: antes pasaba índice 0 fijo → siempre morado.
  // Ahora fromJson usa el id del curso directamente.
  return TeacherCourse.fromJson(res as Map<String, dynamic>);
});
