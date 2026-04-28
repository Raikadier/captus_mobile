import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

final _supabase = Supabase.instance.client;
final _random = Random.secure();
const _archivedPrefix = '[ARCHIVADO] ';

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
      .where((course) => !course.title.startsWith(_archivedPrefix))
      .toList();
});

final teacherArchivedCoursesProvider =
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
      .where((course) => course.title.startsWith(_archivedPrefix))
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

  Future<TeacherCourse?> updateCourse({
    required int courseId,
    required String title,
    required String description,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return null;

    final res = await _supabase
        .from('courses')
        .update({
          'title': title.trim(),
          'description': description.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', courseId)
        .eq('teacher_id', user.id)
        .select('*, course_enrollments(id)')
        .maybeSingle();

    if (res == null) return null;
    final updated = TeacherCourse.fromJson(res as Map<String, dynamic>);
    final current = state.value ?? [];
    state = AsyncData(
      [
        for (final c in current)
          if (c.id == courseId) updated else c,
      ],
    );
    ref.invalidate(teacherCoursesProvider);
    return updated;
  }

  Future<TeacherCourse?> duplicateCourse({
    required TeacherCourse sourceCourse,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return null;

    final inviteCode = _generateCode();
    final duplicateTitle = sourceCourse.title.startsWith(_archivedPrefix)
        ? sourceCourse.title.replaceFirst(_archivedPrefix, '') + ' (Copia)'
        : '${sourceCourse.title} (Copia)';

    final res = await _supabase
        .from('courses')
        .insert({
          'teacher_id': user.id,
          'title': duplicateTitle,
          'description': sourceCourse.description ?? '',
          'invite_code': inviteCode,
        })
        .select('*, course_enrollments(id)')
        .single();

    final duplicated = TeacherCourse.fromJson(res as Map<String, dynamic>);
    state = AsyncData([duplicated, ...?state.value]);
    ref.invalidate(teacherCoursesProvider);
    return duplicated;
  }

  Future<TeacherCourse?> archiveCourse({
    required TeacherCourse course,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return null;

    final currentTitle = course.title.trim();
    final archivedTitle = currentTitle.startsWith(_archivedPrefix)
        ? currentTitle
        : '$_archivedPrefix$currentTitle';

    final res = await _supabase
        .from('courses')
        .update({
          'title': archivedTitle,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', course.id)
        .eq('teacher_id', user.id)
        .select('*, course_enrollments(id)')
        .maybeSingle();

    if (res == null) return null;
    final archived = TeacherCourse.fromJson(res as Map<String, dynamic>);
    final current = state.value ?? [];
    state = AsyncData(
      [
        for (final c in current)
          if (c.id == course.id) archived else c,
      ],
    );
    ref.invalidate(teacherCoursesProvider);
    ref.invalidate(teacherArchivedCoursesProvider);
    return archived;
  }

  Future<TeacherCourse?> unarchiveCourse({
    required TeacherCourse course,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return null;

    final currentTitle = course.title.trim();
    final restoredTitle = currentTitle.startsWith(_archivedPrefix)
        ? currentTitle.replaceFirst(_archivedPrefix, '').trim()
        : currentTitle;

    final res = await _supabase
        .from('courses')
        .update({
          'title': restoredTitle,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', course.id)
        .eq('teacher_id', user.id)
        .select('*, course_enrollments(id)')
        .maybeSingle();

    if (res == null) return null;
    final restored = TeacherCourse.fromJson(res as Map<String, dynamic>);
    final current = state.value ?? [];
    state = AsyncData(
      [
        for (final c in current)
          if (c.id == course.id) restored else c,
      ],
    );
    ref.invalidate(teacherCoursesProvider);
    ref.invalidate(teacherArchivedCoursesProvider);
    return restored;
  }

  Future<void> deleteCourse({
    required int courseId,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final assignmentRows = await _supabase
        .from('course_assignments')
        .select('id')
        .eq('course_id', courseId);
    final assignmentIds = (assignmentRows as List)
        .map((row) => (row as Map<String, dynamic>)['id'])
        .whereType<int>()
        .toList();

    final groupRows = await _supabase
        .from('course_groups')
        .select('id')
        .eq('course_id', courseId);
    final groupIds = (groupRows as List)
        .map((row) => (row as Map<String, dynamic>)['id'])
        .whereType<int>()
        .toList();

    if (assignmentIds.isNotEmpty) {
      await _supabase
          .from('assignment_submissions')
          .delete()
          .inFilter('assignment_id', assignmentIds);
    }

    if (groupIds.isNotEmpty) {
      await _supabase
          .from('assignment_submissions')
          .delete()
          .inFilter('group_id', groupIds);
      await _supabase
          .from('course_group_members')
          .delete()
          .inFilter('group_id', groupIds);
    }

    await _supabase.from('course_enrollments').delete().eq('course_id', courseId);
    await _supabase.from('course_assignments').delete().eq('course_id', courseId);
    await _supabase.from('course_groups').delete().eq('course_id', courseId);
    await _supabase
        .from('courses')
        .delete()
        .eq('id', courseId)
        .eq('teacher_id', user.id);

    final current = state.value ?? [];
    state = AsyncData(current.where((c) => c.id != courseId).toList());
    ref.invalidate(teacherCoursesProvider);
    ref.invalidate(teacherArchivedCoursesProvider);
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
    final profile = (json['users'] ?? json['profiles']) as Map<String, dynamic>? ?? {};
    return EnrolledStudent(
      id: profile['id']?.toString() ?? '',
      name: profile['name']?.toString() ?? 'Sin nombre',
      email: profile['email']?.toString() ?? '',
      avatarUrl: (profile['avatarUrl'] ?? profile['avatar_url'])?.toString(),
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
      .select('enrolled_at, student_id')
      .eq('course_id', courseId);

  final enrollments = (res as List).cast<Map<String, dynamic>>();
  if (enrollments.isEmpty) return [];

  final studentIds = enrollments
      .map((e) => e['student_id']?.toString() ?? '')
      .where((id) => id.isNotEmpty)
      .toSet()
      .toList();

  Map<String, Map<String, dynamic>> usersById = {};
  try {
    final usersRes = await _supabase
        .from('users')
        .select('id, name, email, avatarUrl')
        .inFilter('id', studentIds);

    final usersList = (usersRes as List).cast<Map<String, dynamic>>();
    usersById = {
      for (final user in usersList) (user['id']?.toString() ?? ''): user,
    };
  } catch (_) {
    // If user detail query fails (RLS/permissions), we still show enrollment rows.
  }

  return enrollments.map((enrollment) {
    final studentId = enrollment['student_id']?.toString() ?? '';
    final userData = usersById[studentId];
    return EnrolledStudent(
      id: studentId,
      name: userData?['name']?.toString() ?? 'Estudiante',
      email: userData?['email']?.toString() ?? '',
      avatarUrl: userData?['avatarUrl']?.toString(),
      enrolledAt:
          DateTime.tryParse(enrollment['enrolled_at']?.toString() ?? '') ??
              DateTime.now(),
    );
  }).toList();
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
