
enum RiskLevel {
  high,
  medium,
  low,
}

class TeacherStudentStatsModel {
  final String studentId;
  final String studentName;
  final int totalAssignments;
  final int submittedAssignments;
  final int missingAssignments;
  final int gradedSubmissions;
  final double averageGrade;
  final double completionRate;
  final RiskLevel riskLevel;
  final DateTime? lastSubmissionDate;

  TeacherStudentStatsModel({
    required this.studentId,
    required this.studentName,
    required this.totalAssignments,
    required this.submittedAssignments,
    required this.missingAssignments,
    required this.gradedSubmissions,
    required this.averageGrade,
    required this.completionRate,
    required this.riskLevel,
    this.lastSubmissionDate,
  });

  factory TeacherStudentStatsModel.fromMap(Map<String, dynamic> map) {
    return TeacherStudentStatsModel(
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? 'Desconocido',
      totalAssignments: map['totalAssignments'] ?? 0,
      submittedAssignments: map['submittedAssignments'] ?? 0,
      missingAssignments: map['missingAssignments'] ?? 0,
      gradedSubmissions: map['gradedSubmissions'] ?? 0,
      averageGrade: (map['averageGrade'] ?? 0.0).toDouble(),
      completionRate: (map['completionRate'] ?? 0.0).toDouble(),
      riskLevel: _parseRiskLevel(map['riskLevel']),
      lastSubmissionDate: map['lastSubmissionDate'] != null
          ? DateTime.tryParse(map['lastSubmissionDate'])
          : null,
    );
  }

  static RiskLevel _parseRiskLevel(String? level) {
    switch (level) {
      case 'high':
        return RiskLevel.high;
      case 'medium':
        return RiskLevel.medium;
      case 'low':
        return RiskLevel.low;
      default:
        return RiskLevel.low;
    }
  }
}

class TeacherStatsSummaryModel {
  final int totalStudents;
  final int totalAssignments;
  final int totalSubmissions;
  final int pendingToGrade;
  final double averageGrade;
  final int highPerformanceCount;
  final int mediumPerformanceCount;
  final int riskCount;
  final double highPerformancePercentage;
  final double mediumPerformancePercentage;
  final double riskPercentage;
  final List<TeacherStudentStatsModel> students;

  TeacherStatsSummaryModel({
    required this.totalStudents,
    required this.totalAssignments,
    required this.totalSubmissions,
    required this.pendingToGrade,
    required this.averageGrade,
    required this.highPerformanceCount,
    required this.mediumPerformanceCount,
    required this.riskCount,
    required this.highPerformancePercentage,
    required this.mediumPerformancePercentage,
    required this.riskPercentage,
    required this.students,
  });

  factory TeacherStatsSummaryModel.empty() {
    return TeacherStatsSummaryModel(
      totalStudents: 0,
      totalAssignments: 0,
      totalSubmissions: 0,
      pendingToGrade: 0,
      averageGrade: 0.0,
      highPerformanceCount: 0,
      mediumPerformanceCount: 0,
      riskCount: 0,
      highPerformancePercentage: 0.0,
      mediumPerformancePercentage: 0.0,
      riskPercentage: 0.0,
      students: [],
    );
  }
}
