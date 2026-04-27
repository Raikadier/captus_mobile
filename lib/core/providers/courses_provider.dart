import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

final _supabase = Supabase.instance.client;

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

  factory TeacherCourse.fromJson(Map<String, dynamic> json, int index) {
    final enrollments = json['course_enrollments'] as List? ?? [];
    return TeacherCourse(
      id: json['id'] as int,
      title: json['title']?.toString() ?? '',
      inviteCode: json['invite_code']?.toString() ?? '',
      description: json['description']?.toString(),
      studentCount: enrollments.length,
      colorIndex: index % 6,
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
  return list.asMap().entries.map((e) {
    return TeacherCourse.fromJson(e.value as Map<String, dynamic>, e.key);
  }).toList();
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
    return list.asMap().entries.map((e) {
      return TeacherCourse.fromJson(e.value as Map<String, dynamic>, e.key);
    }).toList();
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

    final newCourse = TeacherCourse.fromJson(
        res as Map<String, dynamic>, state.value?.length ?? 0);

    state = AsyncData([newCourse, ...?state.value]);
    return newCourse;
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = List.generate(6,
        (_) => chars[(DateTime.now().microsecondsSinceEpoch) % chars.length]);
    return random.join();
  }
}

final teacherCoursesNotifierProvider =
    AsyncNotifierProvider<TeacherCoursesNotifier, List<TeacherCourse>>(
        TeacherCoursesNotifier.new);
