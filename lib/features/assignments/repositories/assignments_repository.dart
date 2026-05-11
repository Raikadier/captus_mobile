import '../../../models/assignment.dart';
import '../../../models/submission.dart';

abstract class AssignmentsRepository {
  Future<AssignmentModel> createAssignment(AssignmentModel assignment);
  Future<AssignmentModel> updateAssignment(AssignmentModel assignment);
  Future<void> deleteAssignment(String assignmentId);

  Future<List<AssignmentModel>> getAssignmentsByTeacher(String teacherId);
  Future<List<AssignmentModel>> getAssignmentsForStudent(String studentId);

  Future<void> assignToGroup(String assignmentId, String groupId);
  Future<void> assignToStudent(String assignmentId, String studentId);

  Future<SubmissionModel> createSubmission(SubmissionModel submission);
  Future<SubmissionModel> updateSubmission(SubmissionModel submission);
  Future<List<SubmissionModel>> getSubmissionsByAssignment(String assignmentId);

  Future<void> gradeSubmission(
      String submissionId, double grade, String feedback);

  Future<Map<String, dynamic>> getTeacherStats(String teacherId);

  Future<List<Map<String, dynamic>>> getRecentSubmissionsByTeacher(
      String teacherId,
      {int limit = 5});
}
