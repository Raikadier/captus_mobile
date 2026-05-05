import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/teacher_stats_model.dart';

class TeacherStatsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<TeacherStatsSummaryModel> getTeacherStats({String? courseId}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return TeacherStatsSummaryModel.empty();

      // 1. Get courses for this teacher
      var coursesQuery = _client.from('courses').select('id, name').eq('teacher_id', userId);
      if (courseId != null) {
        coursesQuery = coursesQuery.eq('id', courseId);
      }
      final coursesData = await coursesQuery;
      final courseIds = (coursesData as List).map((c) => c['id']).toList();

      if (courseIds.isEmpty) return TeacherStatsSummaryModel.empty();

      // 2. Get all assignments for these courses
      final assignmentsData = await _client
          .from('course_assignments')
          .select('id, course_id, due_date')
          .filter('course_id', 'in', courseIds);
      
      final totalAssignments = (assignmentsData as List).length;

      // 3. Get all students in these courses
      // First get course groups
      final courseGroupsData = await _client
          .from('course_groups')
          .select('id, course_id')
          .filter('course_id', 'in', courseIds);
      
      final groupIds = (courseGroupsData as List).map((g) => g['id']).toList();
      
      if (groupIds.isEmpty) {
         return TeacherStatsSummaryModel.empty();
      }

      // Then get group members (students)
      final membersData = await _client
          .from('group_members')
          .select('user_id, profiles!inner(full_name, role)')
          .filter('group_id', 'in', groupIds)
          .eq('profiles.role', 'student');

      // Unique students
      final studentsMap = <String, String>{};
      for (var m in (membersData as List)) {
        studentsMap[m['user_id']] = m['profiles']['full_name'];
      }
      final studentIds = studentsMap.keys.toList();
      final totalStudents = studentIds.length;

      if (totalStudents == 0) {
        return TeacherStatsSummaryModel(
          totalStudents: 0,
          totalAssignments: totalAssignments,
          totalSubmissions: 0,
          pendingToGrade: 0,
          averageGrade: 0,
          highPerformanceCount: 0,
          mediumPerformanceCount: 0,
          riskCount: 0,
          highPerformancePercentage: 0,
          mediumPerformancePercentage: 0,
          riskPercentage: 0,
          students: [],
        );
      }

      // 4. Get all submissions for these assignments
      final assignmentIds = (assignmentsData as List).map((a) => a['id']).toList();
      final submissionsData = await _client
          .from('assignment_submissions')
          .select('id, assignment_id, student_id, grade, graded, submitted_at')
          .filter('assignment_id', 'in', assignmentIds);
      
      final submissionsList = submissionsData as List;
      final totalSubmissions = submissionsList.length;
      final pendingToGrade = submissionsList.where((s) => s['graded'] == false).length;

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
        
        final averageGrade = gradedCount > 0 ? totalGrades / gradedCount : 0.0;
        final completionRate = totalAssignments > 0 ? (submittedCount / totalAssignments) * 100 : 0.0;
        final missingAssignments = totalAssignments - submittedCount;

        // Check for late submissions (simplified: if submitted_at > due_date)
        bool hasLateSubmissions = false;
        DateTime? lastSubmission;

        for (var sub in studentSubmissions) {
          final subDate = DateTime.tryParse(sub['submitted_at'] ?? '');
          if (subDate != null) {
            if (lastSubmission == null || subDate.isAfter(lastSubmission)) {
              lastSubmission = subDate;
            }
            
            // Find assignment due date
            final assignment = (assignmentsData as List).firstWhere((a) => a['id'] == sub['assignment_id'], orElse: () => null);
            if (assignment != null && assignment['due_date'] != null) {
              final dueDate = DateTime.tryParse(assignment['due_date']);
              if (dueDate != null && subDate.isAfter(dueDate)) {
                hasLateSubmissions = true;
              }
            }
          }
        }

        // Risk Logic
        RiskLevel risk;
        if (averageGrade < 3.0 || completionRate < 70 || missingAssignments > 0 || hasLateSubmissions) {
          risk = RiskLevel.high; // High risk (Inmerso en riesgo)
        } else if (averageGrade >= 3.5 && averageGrade <= 5.0 && completionRate >= 70) {
          risk = RiskLevel.low; // Low risk (Alto rendimiento)
        } else if (averageGrade >= 3.0 && averageGrade < 3.5 && completionRate >= 70) {
          risk = RiskLevel.medium; // Medium risk (Rendimiento medio)
        } else {
          risk = RiskLevel.high; // Default to risk if doesn't fit high/medium
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
          lastSubmissionDate: lastSubmission,
        ));
      }

      // Summary calcs
      final highPerf = studentStats.where((s) => s.riskLevel == RiskLevel.low).length;
      final medPerf = studentStats.where((s) => s.riskLevel == RiskLevel.medium).length;
      final riskPerf = studentStats.where((s) => s.riskLevel == RiskLevel.high).length;
      
      double totalAvg = 0;
      int studentsWithGrades = 0;
      for (var s in studentStats) {
        if (s.gradedSubmissions > 0) {
          totalAvg += s.averageGrade;
          studentsWithGrades++;
        }
      }
      final overallAverage = studentsWithGrades > 0 ? totalAvg / studentsWithGrades : 0.0;

      return TeacherStatsSummaryModel(
        totalStudents: totalStudents,
        totalAssignments: totalAssignments,
        totalSubmissions: totalSubmissions,
        pendingToGrade: pendingToGrade,
        averageGrade: overallAverage,
        highPerformanceCount: highPerf,
        mediumPerformanceCount: medPerf,
        riskCount: riskPerf,
        highPerformancePercentage: totalStudents > 0 ? (highPerf / totalStudents) : 0,
        mediumPerformancePercentage: totalStudents > 0 ? (medPerf / totalStudents) : 0,
        riskPercentage: totalStudents > 0 ? (riskPerf / totalStudents) : 0,
        students: studentStats,
      );
    } catch (e) {
      return TeacherStatsSummaryModel.empty();
    }
  }
}
