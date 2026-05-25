import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/assignment.dart';
import '../../../models/submission.dart';
import 'assignments_repository.dart';

class SupabaseAssignmentsRepository implements AssignmentsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<AssignmentModel> createAssignment(AssignmentModel assignment) async {
    final payload = assignment.toJson();
    if (payload['id'] == '' || payload['id'] == '0') {
      payload.remove('id'); // Dejar que Supabase genere el ID autoincremental
    }
    
    // Limpieza de campos que podrían no existir en la tabla o causar conflictos
    payload.remove('course'); 
    payload.remove('submissions');

    // Validación obligatoria de restricciones CHECK
    final forbiddenTypes = ['course', 'group', 'student'];
    if (forbiddenTypes.contains(payload['tipo_asignacion'])) {
      payload['tipo_asignacion'] = 'tarea';
    }

    if (payload['priority'] == 'medium') {
      payload['priority'] = 'medio';
    } else if (payload['priority'] == 'low') {
       payload['priority'] = 'bajo';
    } else if (payload['priority'] == 'high') {
       payload['priority'] = 'alto';
    }

    try {
      debugPrint('PRE-INSERT PAYLOAD: $payload');
      final response = await _client
          .from('course_assignments')
          .insert(payload)
          .select()
          .single();
      debugPrint('CREATE_ASSIGNMENT_SUCCESS: $response');
      return AssignmentModel.fromJson(response);
    } catch (e) {
      debugPrint('ASSIGNMENT_CREATE_ERROR: $e');
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
      throw Exception('Error al crear tarea: $e');
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
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
      throw Exception('Error al actualizar tarea: $e');
    }
  }

  @override
  Future<void> deleteAssignment(String assignmentId) async {
    try {
      await _client.from('course_assignments').delete().eq('id', assignmentId);
    } catch (e) {
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
      throw Exception('Error al eliminar tarea: $e');
    }
  }

  @override
  Future<List<AssignmentModel>> getAssignmentsByTeacher(
      String teacherId) async {
    try {
      final res = await _client
          .from('course_assignments')
          .select()
          .eq('teacher_id', teacherId)
          .order('created_at', ascending: false);

      return (res as List).map((e) => AssignmentModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('LOAD_ASSIGNMENTS_ERROR: $e');
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<List<AssignmentModel>> getAssignmentsForStudent(
      String studentId) async {
    try {
      // 1. Obtener cursos del estudiante vía inscripciones o grupos
      final enrollmentsRes = await _client
          .from('course_enrollments')
          .select('course_id')
          .eq('student_id', studentId);

      final Set<String> courseIds = (enrollmentsRes as List)
          .map((row) => row['course_id'].toString())
          .toSet();

      if (courseIds.isEmpty) return [];

      // 2. Traer tareas de esos cursos
      final res = await _client
          .from('course_assignments')
          .select()
          .filter('course_id', 'in', courseIds.toList())
          .order('due_date', ascending: true);

      return (res as List).map((e) => AssignmentModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('LOAD_STUDENT_ASSIGNMENTS_ERROR: $e');
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
      throw Exception('Error al cargar tareas del estudiante: $e');
    }
  }

  @override
  Future<void> assignToGroup(String assignmentId, String groupId) async {
    try {
      await _client.from('assignment_submissions').insert({
        'assignment_id': int.parse(assignmentId),
        'group_id': int.parse(groupId),
        'student_id': null, // Es grupal
        'graded': false,
      });
    } catch (e) {
      debugPrint('Error assignToGroup: $e');
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<void> assignToStudent(String assignmentId, String studentId) async {
    try {
      await _client.from('assignment_submissions').insert({
        'assignment_id': int.parse(assignmentId),
        'student_id': studentId,
        'group_id': null, // Es individual
        'graded': false,
      });
    } catch (e) {
      debugPrint('Error assignToStudent: $e');
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<SubmissionModel> createSubmission(SubmissionModel submission) async {
    try {
      final data = submission.toJson();
      if (data['id'] == '' || data['id'] == '0') {
        data.remove('id');
      }
      final res = await _client
          .from('assignment_submissions')
          .insert(data)
          .select()
          .single();
      return SubmissionModel.fromJson(res);
    } catch (e) {
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
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
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
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
      debugPrint('GET_SUBMISSIONS_ERROR: $e');
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
      throw Exception('Error al cargar entregas: $e');
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
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
      throw Exception('Error al calificar entrega: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getTeacherStats(String teacherId) async {
    try {
      // Total de tareas creadas por el docente
      final assignmentsRes = await _client
          .from('course_assignments')
          .select('id')
          .eq('teacher_id', teacherId);
      final totalAssignments = (assignmentsRes as List).length;

      // Entregas pendientes de calificar
      // Buscamos entregas de tareas que pertenecen a este docente
      final pendingRes = await _client
          .from('assignment_submissions')
          .select('id, course_assignments!inner(teacher_id)')
          .eq('course_assignments.teacher_id', teacherId)
          .eq('graded', false);

      final pendingToGrade = (pendingRes as List).length;

      return {
        'totalAssignments': totalAssignments,
        'pendingToGrade': pendingToGrade,
      };
    } catch (e) {
      debugPrint('STATS_ERROR: $e');
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
      throw Exception('Error al cargar estadísticas del docente: $e');
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
              '*, course_assignments!inner(title, teacher_id)')
          .eq('course_assignments.teacher_id', teacherId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(res.map((e) {
        return {
          'id': e['id'],
          'studentId': e['student_id'] ?? e['user_id'],
          'assignmentId': e['assignment_id'],
          'title': e['course_assignments']['title'],
          'status': e['graded'] == true ? 'graded' : 'submitted',
          'grade': e['grade'],
          'submittedAt': e['created_at'],
        };
      }));
    } catch (e) {
      debugPrint('RECENT_SUBMISSIONS_ERROR: $e');
      if (e is PostgrestException) {
        throw Exception('Error Supabase (${e.code}): ${e.message}');
      }
      throw Exception('Error al cargar entregas recientes: $e');
    }
  }

  @override
  Future<String?> uploadFile(dynamic file, String fileName) async {
    try {
      final path = 'assignments/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      await _client.storage.from('assignments').uploadBinary(path, file);
      final url = _client.storage.from('assignments').getPublicUrl(path);
      return url;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      if (e is StorageException) {
        throw Exception('Error de almacenamiento (${e.error}): ${e.message}');
      }
      throw Exception('Error al subir archivo: $e');
    }
  }
}
