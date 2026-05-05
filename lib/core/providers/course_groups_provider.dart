import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_provider.dart';

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
  },
);

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
      // Placeholder logic to return an empty list safely
      return <EnrolledStudent>[];
    } catch (e) {
      return <EnrolledStudent>[];
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

    final groupRes = await _supabase
        .from('course_groups')
        .insert({
          'course_id': courseId,
          'name': name.trim(),
          'description': (description ?? '').trim(),
          'created_by': user.id,
        })
        .select('id')
        .single();

    final groupId = groupRes['id'] as int;

    if (memberIds.isNotEmpty) {
      final rows = memberIds
          .map((studentId) => {
                'group_id': groupId,
                'student_id': studentId,
              })
          .toList();
      await _supabase.from('course_group_members').insert(rows);
    }

    ref.invalidate(courseGroupsProvider(courseId));
    ref.invalidate(unassignedCourseStudentsProvider(courseId));
    return groupId;
  }

  Future<void> addMember({
    required int courseId,
    required int groupId,
    required String studentId,
  }) async {
    await _supabase.from('course_group_members').insert({
      'group_id': groupId,
      'student_id': studentId,
    });
    ref.invalidate(groupMembersProvider(groupId));
    ref.invalidate(courseGroupsProvider(courseId));
    ref.invalidate(unassignedCourseStudentsProvider(courseId));
  }

  Future<void> removeMember({
    required int courseId,
    required int groupId,
    required String studentId,
  }) async {
    await _supabase
        .from('course_group_members')
        .delete()
        .eq('group_id', groupId)
        .eq('student_id', studentId);
    ref.invalidate(groupMembersProvider(groupId));
    ref.invalidate(courseGroupsProvider(courseId));
    ref.invalidate(unassignedCourseStudentsProvider(courseId));
  }

  Future<void> assignTaskToGroup({
    required int courseId,
    required int groupId,
    required String title,
    String? description,
    required DateTime dueDate,
  }) async {
    final assignmentRes = await _supabase
        .from('course_assignments')
        .insert({
          'course_id': courseId,
          'title': title.trim(),
          'description': (description ?? '').trim(),
          'due_date': dueDate.toIso8601String(),
          'is_group_assignment': true,
        })
        .select('id')
        .single();

    await _supabase.from('assignment_submissions').insert({
      'assignment_id': assignmentRes['id'] as int,
      'group_id': groupId,
    });

    ref.invalidate(groupAssignmentsProvider(groupId));
  }

  Future<void> deleteGroup({
    required int courseId,
    required int groupId,
  }) async {
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
  }
}

final courseGroupsNotifierProvider =
    AsyncNotifierProvider<CourseGroupsNotifier, void>(CourseGroupsNotifier.new);
