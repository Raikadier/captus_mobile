import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/assignment.dart';
import '../../../models/submission.dart';
import 'assignments_repository.dart';

class SupabaseAssignmentsRepository implements AssignmentsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<AssignmentModel> createAssignment(AssignmentModel assignment) async {
    try {
      final data = assignment.toJson();
      if (data['id'] == '') {
        data.remove('id'); // Dejar que Supabase genere el ID autoincremental
      }
      final response = await _client
          .from('course_assignments')
          .insert(data)
          .select()
          .single();
      return AssignmentModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear tarea en Supabase: $e');
    }
  }

  @override
  Future<AssignmentModel> updateAssignment(AssignmentModel assignment) async {
    try {
      final response = await _client
          .from('course_assignments')
          .update(assignment.toJson())
          .eq('id', assignment.id)
          .select()
          .single();
      return AssignmentModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar tarea en Supabase: $e');
    }
  }

  @override
  Future<void> deleteAssignment(String assignmentId) async {
    try {
      await _client.from('course_assignments').delete().eq('id', assignmentId);
    } catch (e) {
      throw Exception('Error al eliminar tarea en Supabase: $e');
    }
  }

  @override
  Future<List<AssignmentModel>> getAssignmentsByTeacher(
      String teacherId) async {
    try {
      // Unir con courses para filtrar por teacher_id
      final res = await _client
          .from('course_assignments')
          .select('*, courses!inner(teacher_id)')
          .eq('courses.teacher_id', teacherId)
          .order('created_at', ascending: false);

      return (res as List).map((e) => AssignmentModel.fromJson(e)).toList();
    } catch (e) {
      return []; // Respuesta vacía segura
    }
  }

  @override
  Future<List<AssignmentModel>> getAssignmentsForStudent(
      String studentId) async {
    try {
      // 1. Obtener a qué cursos pertenece el estudiante (basado en group_members y course_groups)
      final groupsRes = await _client
          .from('group_members')
          .select('course_groups!inner(course_id)')
          .eq('user_id', studentId);

      final Set<String> courseIds = {};
      for (var row in (groupsRes as List)) {
        final cId = row['course_groups']?['course_id']?.toString();
        if (cId != null) courseIds.add(cId);
      }

      if (courseIds.isEmpty) return [];

      // 2. Traer course_assignments de esos cursos
      final res = await _client
          .from('course_assignments')
          .select()
          .filter('course_id', 'in', courseIds.toList())
          .order('due_date', ascending: true);

      return (res as List).map((e) => AssignmentModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> assignToGroup(String assignmentId, String groupId) async {
    // No aplica: en esta versión, is_group_assignment = true indica que
    // se asigna automáticamente a los grupos del curso.
  }

  @override
  Future<void> assignToStudent(String assignmentId, String studentId) async {
    // No aplica: no usamos assignment_targets para estudiantes individuales.
  }

  @override
  Future<SubmissionModel> createSubmission(SubmissionModel submission) async {
    try {
      final data = submission.toJson();
      if (data['id'] == '') {
        data.remove('id');
      }
      final res = await _client
          .from('assignment_submissions')
          .insert(data)
          .select()
          .single();
      return SubmissionModel.fromJson(res);
    } catch (e) {
      throw Exception('Error al crear entrega: $e');
    }
  }

  @override
  Future<SubmissionModel> updateSubmission(SubmissionModel submission) async {
    try {
      final res = await _client
          .from('assignment_submissions')
          .update(submission.toJson())
          .eq('id', submission.id)
          .select()
          .single();
      return SubmissionModel.fromJson(res);
    } catch (e) {
      throw Exception('Error al actualizar entrega: $e');
    }
  }

  @override
  Future<List<SubmissionModel>> getSubmissionsByAssignment(
      String assignmentId) async {
    try {
      final res = await _client
          .from('assignment_submissions')
          .select()
          .eq('assignment_id', assignmentId)
          .order('created_at', ascending: false);
      return (res as List).map((e) => SubmissionModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> gradeSubmission(
      String submissionId, double grade, String feedback) async {
    try {
      await _client.from('assignment_submissions').update({
        'grade': grade,
        'feedback': feedback,
        'graded': true,
      }).eq('id', submissionId);
    } catch (e) {
      throw Exception('Error al calificar entrega: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getTeacherStats(String teacherId) async {
    try {
      final assignmentsRes = await _client
          .from('course_assignments')
          .select('id, courses!inner(teacher_id)')
          .eq('courses.teacher_id', teacherId);
      final totalAssignments = (assignmentsRes as List).length;

      final pendingRes = await _client
          .from('assignment_submissions')
          .select('id, course_assignments!inner(courses!inner(teacher_id))')
          .eq('course_assignments.courses.teacher_id', teacherId)
          .eq('graded', false);

      final pendingToGrade = (pendingRes as List).length;

      return {
        'totalAssignments': totalAssignments,
        'pendingToGrade': pendingToGrade,
      };
    } catch (e) {
      return {
        'totalAssignments': 0,
        'pendingToGrade': 0,
      };
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentSubmissionsByTeacher(
      String teacherId,
      {int limit = 5}) async {
    try {
      final res = await _client
          .from('assignment_submissions')
          .select(
              '*, course_assignments!inner(title, courses!inner(teacher_id))')
          .eq('course_assignments.courses.teacher_id', teacherId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(res.map((e) {
        return {
          'id': e['id'],
          'studentId': e['user_id'] ?? e['student_id'],
          'assignmentId': e['assignment_id'],
          'title': e['course_assignments']['title'],
          'status': e['graded'] == true ? 'graded' : 'submitted',
          'grade': e['grade'],
          'submittedAt': e['created_at'],
        };
      }));
    } catch (e) {
      return [];
    }
  }
}
