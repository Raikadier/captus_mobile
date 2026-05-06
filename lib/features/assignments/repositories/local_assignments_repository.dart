import 'package:uuid/uuid.dart';
import '../../../core/database/database_service.dart';
import '../../../models/assignment.dart';
import '../../../models/assignment_target.dart';
import '../../../models/submission.dart';
import 'assignments_repository.dart';

class LocalAssignmentsRepository implements AssignmentsRepository {
  final _uuid = const Uuid();

  @override
  Future<AssignmentModel> createAssignment(AssignmentModel assignment) async {
    final assignmentToSave = assignment.id.isEmpty
        ? assignment.copyWith(id: _uuid.v4())
        : assignment;

    await DatabaseService.insert('assignments', assignmentToSave.toJson());
    return assignmentToSave;
  }

  @override
  Future<AssignmentModel> updateAssignment(AssignmentModel assignment) async {
    await DatabaseService.update(
      'assignments',
      assignment.toJson(),
      where: 'id = ?',
      whereArgs: [assignment.id],
    );
    return assignment;
  }

  @override
  Future<void> deleteAssignment(String assignmentId) async {
    await DatabaseService.delete('assignments',
        where: 'id = ?', whereArgs: [assignmentId]);
  }

  @override
  Future<List<AssignmentModel>> getAssignmentsByTeacher(
      String teacherId) async {
    final res = await DatabaseService.query('assignments',
        where: 'teacher_id = ?', whereArgs: [teacherId]);
    return res.map((e) => AssignmentModel.fromJson(e)).toList();
  }

  @override
  Future<List<AssignmentModel>> getAssignmentsForStudent(
      String studentId) async {
    // Para simplificar localmente: Traeremos las asignaciones basadas en targets de estudiante.
    // También se podría hacer un JOIN complejo si dependiera del curso.
    final targets = await DatabaseService.query('assignment_targets',
        where: 'target_id = ? AND target_type = ?',
        whereArgs: [studentId, 'student']);

    List<AssignmentModel> studentAssignments = [];
    for (final target in targets) {
      final aId = target['assignment_id'];
      final asg = await DatabaseService.query('assignments',
          where: 'id = ?', whereArgs: [aId]);
      if (asg.isNotEmpty) {
        studentAssignments.add(AssignmentModel.fromJson(asg.first));
      }
    }
    return studentAssignments;
  }

  @override
  Future<void> assignToGroup(String assignmentId, String groupId) async {
    final target = AssignmentTargetModel(
      id: _uuid.v4(),
      assignmentId: assignmentId,
      targetType: 'group',
      targetId: groupId,
    );
    await DatabaseService.insert('assignment_targets', target.toJson());
  }

  @override
  Future<void> assignToStudent(String assignmentId, String studentId) async {
    final target = AssignmentTargetModel(
      id: _uuid.v4(),
      assignmentId: assignmentId,
      targetType: 'student',
      targetId: studentId,
    );
    await DatabaseService.insert('assignment_targets', target.toJson());
  }

  @override
  Future<SubmissionModel> createSubmission(SubmissionModel submission) async {
    final subToSave = submission.id.isEmpty
        ? submission.copyWith(id: _uuid.v4())
        : submission;
    await DatabaseService.insert('submissions', subToSave.toJson());
    return subToSave;
  }

  @override
  Future<SubmissionModel> updateSubmission(SubmissionModel submission) async {
    await DatabaseService.update(
      'submissions',
      submission.toJson(),
      where: 'id = ?',
      whereArgs: [submission.id],
    );
    return submission;
  }

  @override
  Future<List<SubmissionModel>> getSubmissionsByAssignment(
      String assignmentId) async {
    final res = await DatabaseService.query('submissions',
        where: 'assignment_id = ?', whereArgs: [assignmentId]);
    return res.map((e) => SubmissionModel.fromJson(e)).toList();
  }

  @override
  Future<void> gradeSubmission(
      String submissionId, double grade, String feedback) async {
    await DatabaseService.update(
      'submissions',
      {'grade': grade, 'feedback': feedback, 'status': 'graded'},
      where: 'id = ?',
      whereArgs: [submissionId],
    );
  }

  @override
  Future<Map<String, dynamic>> getTeacherStats(String teacherId) async {
    // Mocked stats for local testing
    return {
      'totalAssignments': 10,
      'pendingToGrade': 5,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentSubmissionsByTeacher(
      String teacherId,
      {int limit = 5}) async {
    final assignments = await getAssignmentsByTeacher(teacherId);
    if (assignments.isEmpty) return [];

    final assignmentIds = assignments.map((a) => a.id).toList();
    final placeholders = List.filled(assignmentIds.length, '?').join(',');

    final db = await DatabaseService.database;
    final submissionsRaw = await db.query(
      'submissions',
      where: 'assignment_id IN ($placeholders)',
      whereArgs: assignmentIds,
      orderBy: 'submitted_at DESC',
      limit: limit,
    );

    List<Map<String, dynamic>> result = [];
    for (final sub in submissionsRaw) {
      final aId = sub['assignment_id'] as String;
      final assignment = assignments.firstWhere(
        (a) => a.id == aId,
        orElse: () => assignments.first,
      );
      if (assignments.isEmpty) continue;

      result.add({
        'id': sub['id'],
        'studentId': sub['student_id'],
        'assignmentId': aId,
        'title': assignment.title,
        'status': sub['status'],
        'grade': sub['grade'],
        'submittedAt': sub['submitted_at'],
      });
    }

    return result;
  }
}
