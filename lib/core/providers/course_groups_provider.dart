import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_provider.dart';
import 'courses_provider.dart';

final _supabase = Supabase.instance.client;

class CourseGroup {
  final int id;
  final int courseId;
  final String name;
  final String? description;
  final String createdBy;
  final DateTime createdAt;
  final int memberCount;

  const CourseGroup({
    required this.id,
    required this.courseId,
    required this.name,
    this.description,
    required this.createdBy,
    required this.createdAt,
    required this.memberCount,
  });

  factory CourseGroup.fromJson(Map<String, dynamic> json) {
    final members = (json['course_group_members'] as List?) ?? const [];
    return CourseGroup(
      id: json['id'] as int,
      courseId: json['course_id'] as int,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      memberCount: members.length,
    );
  }
}

class GroupMember {
  final int id;
  final int groupId;
  final String studentId;
  final String name;
  final String email;
  final String? avatarUrl;

  const GroupMember({
    required this.id,
    required this.groupId,
    required this.studentId,
    required this.name,
    required this.email,
    this.avatarUrl,
  });
}

class EnrolledStudent {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  const EnrolledStudent({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });
}

class GroupAssignment {
  final int submissionId;
  final int assignmentId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final bool graded;
  final num? grade;
  final String? feedback;
  final DateTime? submittedAt;

  const GroupAssignment({
    required this.submissionId,
    required this.assignmentId,
    required this.title,
    this.description,
    required this.dueDate,
    required this.graded,
    this.grade,
    this.feedback,
    this.submittedAt,
  });
}

final courseGroupsProvider =
    FutureProvider.autoDispose.family<List<CourseGroup>, int>(
  (ref, courseId) async {
    try {
      final res = await _supabase
          .from('course_groups')
          .select('id, course_id, name, description, created_by, created_at, '
              'course_group_members(id)')
          .eq('course_id', courseId)
          .order('created_at', ascending: true);

      return (res as List)
          .cast<Map<String, dynamic>>()
          .map(CourseGroup.fromJson)
          .toList();
    } catch (e) {
      debugPrint('FETCH_GROUPS_ERROR: $e');
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
      throw Exception('Error al cargar grupos: $e');
    }
  },
);

final teacherGroupsProvider = FutureProvider.autoDispose<List<CourseGroup>>((ref) async {
  try {
    final coursesAsync = ref.watch(coursesProvider);
    final courses = coursesAsync.value ?? [];
    if (courses.isEmpty) return [];
    
    final courseIds = courses.map((c) => int.tryParse(c.id)).whereType<int>().toList();
    if (courseIds.isEmpty) return [];

    final res = await _supabase
        .from('course_groups')
        .select('id, course_id, name, description, created_by, created_at, '
            'course_group_members(id)')
        .inFilter('course_id', courseIds)
        .order('created_at', ascending: false);

    return (res as List)
        .cast<Map<String, dynamic>>()
        .map(CourseGroup.fromJson)
        .toList();
  } catch (e) {
    debugPrint('FETCH_TEACHER_GROUPS_ERROR: $e');
    if (e is PostgrestException) {
      throw Exception('Error Supabase (${e.code}): ${e.message}');
    }
    throw Exception('Error al cargar grupos del docente: $e');
  }
});

final groupMembersProvider =
    FutureProvider.autoDispose.family<List<GroupMember>, int>(
  (ref, groupId) async {
    final membersRes = await _supabase
        .from('course_group_members')
        .select('id, group_id, student_id')
        .eq('group_id', groupId)
        .order('joined_at', ascending: true);

    final memberRows = (membersRes as List).cast<Map<String, dynamic>>();
    if (memberRows.isEmpty) return [];

    final studentIds = memberRows
        .map((e) => e['student_id']?.toString() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    final usersRes = await _supabase
        .from('users')
        .select('id, name, email, avatarUrl')
        .inFilter('id', studentIds);

    final users = (usersRes as List).cast<Map<String, dynamic>>();
    final userById = {
      for (final user in users) (user['id']?.toString() ?? ''): user,
    };

    return memberRows.map((member) {
      final studentId = member['student_id']?.toString() ?? '';
      final user = userById[studentId];
      return GroupMember(
        id: member['id'] as int,
        groupId: member['group_id'] as int,
        studentId: studentId,
        name: user?['name']?.toString() ?? 'Estudiante',
        email: user?['email']?.toString() ?? '',
        avatarUrl: user?['avatarUrl']?.toString(),
      );
    }).toList();
  },
);

final courseStudentsProvider =
    FutureProvider.autoDispose.family<List<EnrolledStudent>, int>(
  (ref, courseId) async {
    try {
      debugPrint('LOAD_STUDENTS_FOR_COURSE: $courseId');
      final res = await _supabase
          .from('course_enrollments')
          .select('student_id, users(id, name, email, avatarUrl)')
          .eq('course_id', courseId);

      final students = (res as List).map((row) {
        final user = row['users'] as Map<String, dynamic>;
        return EnrolledStudent(
          id: user['id']?.toString() ?? '',
          name: user['name']?.toString() ?? 'Estudiante',
          email: user['email']?.toString() ?? '',
          avatarUrl: user['avatarUrl']?.toString(),
        );
      }).toList();
      debugPrint('STUDENTS_FOUND: ${students.length}');
      return students;
    } catch (e) {
      debugPrint('ERROR_LOADING_STUDENTS: $e');
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
      throw Exception('Error al cargar estudiantes del curso: $e');
    }
  },
);

final unassignedCourseStudentsProvider =
    FutureProvider.autoDispose.family<List<EnrolledStudent>, int>(
  (ref, courseId) async {
    final enrolled = await ref.watch(courseStudentsProvider(courseId).future);
    final groups = await ref.watch(courseGroupsProvider(courseId).future);
    if (groups.isEmpty) return enrolled;

    final groupIds = groups.map((g) => g.id).toList();
    final membershipsRes = await _supabase
        .from('course_group_members')
        .select('student_id')
        .inFilter('group_id', groupIds);

    final assignedIds = (membershipsRes as List)
        .map((row) => (row as Map<String, dynamic>)['student_id']?.toString())
        .whereType<String>()
        .toSet();

    return enrolled
        .where((student) => !assignedIds.contains(student.id))
        .toList();
  },
);

final groupAssignmentsProvider =
    FutureProvider.autoDispose.family<List<GroupAssignment>, int>(
  (ref, groupId) async {
    try {
      final submissionsRes = await _supabase
          .from('assignment_submissions')
          .select('id, assignment_id, submitted_at, graded, grade, feedback')
          .eq('group_id', groupId)
          .order('submitted_at', ascending: false);

      final submissions =
          (submissionsRes as List).cast<Map<String, dynamic>>();
      if (submissions.isEmpty) return [];

      final assignmentIds = submissions
          .map((row) => row['assignment_id'])
          .whereType<int>()
          .toSet()
          .toList();

      final assignmentsRes = await _supabase
          .from('course_assignments')
          .select('id, title, description, due_date')
          .inFilter('id', assignmentIds);

      final assignments =
          (assignmentsRes as List).cast<Map<String, dynamic>>();
      final assignmentById = {
        for (final assignment in assignments)
          (assignment['id'] as int): assignment,
      };

      return submissions.map((submission) {
        final assignmentId = submission['assignment_id'] as int;
        final assignment = assignmentById[assignmentId];
        return GroupAssignment(
          submissionId: submission['id'] as int,
          assignmentId: assignmentId,
          title: assignment?['title']?.toString() ?? 'Tarea',
          description: assignment?['description']?.toString(),
          dueDate:
              DateTime.tryParse(assignment?['due_date']?.toString() ?? '') ??
                  DateTime.now(),
          graded: submission['graded'] == true,
          grade: submission['grade'] as num?,
          feedback: submission['feedback']?.toString(),
          submittedAt:
              DateTime.tryParse(submission['submitted_at']?.toString() ?? ''),
        );
      }).toList();
    } catch (e) {
      debugPrint('FETCH_GROUP_ASSIGNMENTS_ERROR: $e');
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
      throw Exception('Error al cargar tareas del grupo: $e');
    }
  },
);

class CourseGroupsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<int> createGroup({
    required int courseId,
    required String name,
    String? description,
    required List<String> memberIds,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    final payload = {
      'course_id': courseId,
      'name': name.trim(),
      'description': (description ?? '').trim(),
      'created_by': user.id,
    };
    debugPrint('CREATE_GROUP_BUTTON_PRESSED');
    debugPrint('CREATE_GROUP_PAYLOAD: $payload');

    try {
      final groupRes = await _supabase
          .from('course_groups')
          .insert(payload)
          .select('id')
          .single();

      debugPrint('GROUP_CREATED_RESPONSE: $groupRes');
      final groupId = groupRes['id'] as int;

      if (memberIds.isNotEmpty) {
        final rows = memberIds
            .map((studentId) => {
                  'group_id': groupId,
                  'student_id': studentId,
                })
            .toList();
        debugPrint('INSERTING_GROUP_MEMBERS: $rows');
        await _supabase.from('course_group_members').insert(rows);
      }

      ref.invalidate(courseGroupsProvider(courseId));
      ref.invalidate(unassignedCourseStudentsProvider(courseId));
      ref.invalidate(teacherGroupsProvider);
      return groupId;
    } catch (e) {
      debugPrint('GROUP_CREATE_ERROR: $e');
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
      throw Exception('Error al crear grupo: $e');
    }
  }

  Future<void> addMember({
    required int courseId,
    required int groupId,
    required String studentId,
  }) async {
    try {
      await _supabase.from('course_group_members').insert({
        'group_id': groupId,
        'student_id': studentId,
      });
      ref.invalidate(groupMembersProvider(groupId));
      ref.invalidate(courseGroupsProvider(courseId));
      ref.invalidate(unassignedCourseStudentsProvider(courseId));
    } catch (e) {
      debugPrint('ADD_MEMBER_ERROR: $e');
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
      throw Exception('Error al añadir miembro: $e');
    }
  }

  Future<void> removeMember({
    required int courseId,
    required int groupId,
    required String studentId,
  }) async {
    try {
      await _supabase
          .from('course_group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('student_id', studentId);
      ref.invalidate(groupMembersProvider(groupId));
      ref.invalidate(courseGroupsProvider(courseId));
      ref.invalidate(unassignedCourseStudentsProvider(courseId));
    } catch (e) {
      debugPrint('REMOVE_MEMBER_ERROR: $e');
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
      throw Exception('Error al eliminar miembro: $e');
    }
  }

  Future<void> assignTaskToGroup({
    required int courseId,
    required int groupId,
    required String title,
    String? description,
    required DateTime dueDate,
  }) async {
    try {
      final assignmentRes = await _supabase
          .from('course_assignments')
          .insert({
            'course_id': courseId,
            'title': title.trim(),
            'description': (description ?? '').trim(),
            'due_date': dueDate.toIso8601String(),
            'is_group_assignment': true,
            'course_group_id': groupId,
            'assignment_type': 'group',
          })
          .select('id')
          .single();

      await _supabase.from('assignment_submissions').insert({
        'assignment_id': assignmentRes['id'] as int,
        'group_id': groupId,
      });

      ref.invalidate(groupAssignmentsProvider(groupId));
    } catch (e) {
      debugPrint('ASSIGN_TASK_ERROR: $e');
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
      throw Exception('Error al asignar tarea: $e');
    }
  }

  Future<void> deleteGroup({
    required int courseId,
    required int groupId,
  }) async {
    try {
      await _supabase
          .from('assignment_submissions')
          .delete()
          .eq('group_id', groupId);
      await _supabase
          .from('course_group_members')
          .delete()
          .eq('group_id', groupId);
      await _supabase.from('course_groups').delete().eq('id', groupId);
      ref.invalidate(courseGroupsProvider(courseId));
      ref.invalidate(unassignedCourseStudentsProvider(courseId));
      ref.invalidate(teacherGroupsProvider);
    } catch (e) {
      debugPrint('DELETE_GROUP_ERROR: $e');
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
      throw Exception('Error al eliminar grupo: $e');
    }
  }
}

final courseGroupsNotifierProvider =
    AsyncNotifierProvider<CourseGroupsNotifier, void>(CourseGroupsNotifier.new);
