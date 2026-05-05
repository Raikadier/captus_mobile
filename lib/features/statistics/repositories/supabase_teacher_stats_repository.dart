import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/teacher_stats_model.dart';
import 'teacher_stats_repository.dart';

class SupabaseTeacherStatsRepository implements TeacherStatsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<TeacherStatsSummaryModel> getTeacherStats({String? courseId}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return TeacherStatsSummaryModel.empty();

      // 1. Get courses for this teacher
      var coursesQuery = _client.from('courses').select('id').eq('teacher_id', userId);
      if (courseId != null) {
        coursesQuery = coursesQuery.eq('id', courseId);
      }
      final List coursesData = await coursesQuery;
      final courseIds = coursesData.map((c) => c['id']).toList();

      if (courseIds.isEmpty) return TeacherStatsSummaryModel.empty();

      // 2. Get all assignments for these courses
      final List assignmentsData = await _client
          .from('course_assignments')
          .select('id, course_id, title, due_date')
          .filter('course_id', 'in', courseIds);
      
      final totalAssignments = assignmentsData.length;

      // 3. Get students
      Map<String, String> studentsMap = {}; // id -> name

      // 3.1 Try groups first
      final List courseGroupsData = await _client
          .from('course_groups')
          .select('id')
          .filter('course_id', 'in', courseIds);
      
      final groupIds = courseGroupsData.map((g) => g['id']).toList();
      
      if (groupIds.isNotEmpty) {
        final List membersData = await _client
            .from('group_members')
            .select('user_id, profiles!inner(full_name, role)')
            .filter('group_id', 'in', groupIds)
            .eq('profiles.role', 'student');

        for (var m in membersData) {
          final profile = m['profiles'] as Map<String, dynamic>?;
          if (profile != null) {
            studentsMap[m['user_id']] = profile['full_name'] ?? 'Estudiante';
          }
        }
      }

      // 4. Get all submissions for these assignments
      final assignmentIds = assignmentsData.map((a) => a['id']).toList();
      List submissionsList = [];
      
      if (assignmentIds.isNotEmpty) {
        final List submissionsData = await _client
            .from('assignment_submissions')
            .select('id, assignment_id, student_id, grade, graded, submitted_at, profiles!inner(full_name)')
            .filter('assignment_id', 'in', assignmentIds);
        submissionsList = submissionsData;

        // 4.1 Fallback: if no students found in groups, get them from submissions
        if (studentsMap.isEmpty) {
          for (var s in submissionsList) {
            final profile = s['profiles'] as Map<String, dynamic>?;
            if (profile != null && !studentsMap.containsKey(s['student_id'])) {
              studentsMap[s['student_id']] = profile['full_name'] ?? 'Estudiante';
            }
          }
        }
      }

      final studentIds = studentsMap.keys.toList();
      final totalStudents = studentIds.length;

      if (totalStudents == 0) {
        return TeacherStatsSummaryModel.empty().copyWith(
          totalAssignments: totalAssignments,
        );
      }

      final int totalSubmissions = submissionsList.length;
      final int pendingToGrade = submissionsList.where((s) => s['graded'] == false).length;

      // 5. Calculate stats per student
      final studentStats = <TeacherStudentStatsModel>[];
      
      for (var entry in studentsMap.entries) {
        final sId = entry.key;
        final sName = entry.value;

        final studentSubmissions = submissionsList.where((s) => s['student_id'] == sId).toList();
        final submittedCount = studentSubmissions.length;
        final gradedSubmissions = studentSubmissions.where((s) => s['graded'] == true).toList();
        final gradedCount = gradedSubmissions.length;
        
        double totalGrades = 0;
        for (var s in gradedSubmissions) {
          totalGrades += (s['grade'] ?? 0.0).toDouble();
        }
        
        final double? averageGrade = gradedCount > 0 ? totalGrades / gradedCount : null;
        final double completionRate = totalAssignments > 0 ? (submittedCount / totalAssignments) : 0.0;
        final int missingAssignments = totalAssignments - submittedCount;

        // Classification Logic
        TeacherStudentRiskLevel risk;
        
        // High performance: avg >= 3.5 && <= 5.0 AND completion >= 70%
        if (averageGrade != null && averageGrade >= 3.5 && averageGrade <= 5.0 && completionRate >= 0.7) {
          risk = TeacherStudentRiskLevel.high;
        } 
        // Medium performance: avg >= 3.0 && < 3.5 AND completion >= 70%
        else if (averageGrade != null && averageGrade >= 3.0 && averageGrade < 3.5 && completionRate >= 0.7) {
          risk = TeacherStudentRiskLevel.medium;
        } 
        // Risk: everything else (avg < 3.0 OR completion < 70% OR missing assignments OR no graded submissions)
        else {
          risk = TeacherStudentRiskLevel.risk;
        }

        studentStats.add(TeacherStudentStatsModel(
          studentId: sId,
          studentName: sName,
          totalAssignments: totalAssignments,
          submittedAssignments: submittedCount,
          missingAssignments: missingAssignments,
          gradedSubmissions: gradedCount,
          averageGrade: averageGrade,
          completionRate: completionRate,
          riskLevel: risk,
          lastSubmissionDate: _getLastSubmissionDate(studentSubmissions),
        ));
      }

      // Summary calcs
      final highPerfCount = studentStats.where((s) => s.riskLevel == TeacherStudentRiskLevel.high).length;
      final medPerfCount = studentStats.where((s) => s.riskLevel == TeacherStudentRiskLevel.medium).length;
      final riskPerfCount = studentStats.where((s) => s.riskLevel == TeacherStudentRiskLevel.risk).length;
      
      double totalAvgSum = 0;
      int studentsWithGrades = 0;
      for (var s in studentStats) {
        if (s.averageGrade != null) {
          totalAvgSum += s.averageGrade!;
          studentsWithGrades++;
        }
      }
      final overallAverage = studentsWithGrades > 0 ? totalAvgSum / studentsWithGrades : null;

      return TeacherStatsSummaryModel(
        totalStudents: totalStudents,
        totalAssignments: totalAssignments,
        totalSubmissions: totalSubmissions,
        pendingToGrade: pendingToGrade,
        averageGrade: overallAverage,
        highPerformanceCount: highPerfCount,
        mediumPerformanceCount: medPerfCount,
        riskCount: riskPerfCount,
        highPerformancePercentage: totalStudents > 0 ? (highPerfCount / totalStudents) : 0,
        mediumPerformancePercentage: totalStudents > 0 ? (medPerfCount / totalStudents) : 0,
        riskPercentage: totalStudents > 0 ? (riskPerfCount / totalStudents) : 0,
        students: studentStats,
      );
    } catch (e) {
      // Return empty instead of throwing to avoid UI crashes
      return TeacherStatsSummaryModel.empty();
    }
  }

  DateTime? _getLastSubmissionDate(List submissions) {
    if (submissions.isEmpty) return null;
    DateTime? last;
    for (var s in submissions) {
      final submittedAt = s['submitted_at'];
      if (submittedAt == null) continue;
      
      final date = DateTime.tryParse(submittedAt.toString());
      if (date != null) {
        if (last == null || date.isAfter(last)) {
          last = date;
        }
      }
    }
    return last;
  }
}
