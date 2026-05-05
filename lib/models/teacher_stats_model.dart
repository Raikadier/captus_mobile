
enum TeacherStudentRiskLevel {
  high,   // Alto rendimiento
  medium, // Rendimiento medio
  risk,   // En riesgo
}

class TeacherStudentStatsModel {
  final String studentId;
  final String studentName;
  final int totalAssignments;
  final int submittedAssignments;
  final int missingAssignments;
  final int gradedSubmissions;
  final double? averageGrade;
  final double completionRate;
  final TeacherStudentRiskLevel riskLevel;
  final DateTime? lastSubmissionDate;

  TeacherStudentStatsModel({
    required this.studentId,
    required this.studentName,
    required this.totalAssignments,
    required this.submittedAssignments,
    required this.missingAssignments,
    required this.gradedSubmissions,
    this.averageGrade,
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
      averageGrade: map['averageGrade'] != null ? (map['averageGrade'] as num).toDouble() : null,
      completionRate: (map['completionRate'] ?? 0.0).toDouble(),
      riskLevel: _parseRiskLevel(map['riskLevel']),
      lastSubmissionDate: map['lastSubmissionDate'] != null
          ? DateTime.tryParse(map['lastSubmissionDate'].toString())
          : null,
    );
  }

  static TeacherStudentRiskLevel _parseRiskLevel(dynamic level) {
    if (level is String) {
      switch (level) {
        case 'high':
          return TeacherStudentRiskLevel.high;
        case 'medium':
          return TeacherStudentRiskLevel.medium;
        case 'risk':
          return TeacherStudentRiskLevel.risk;
      }
    }
    return TeacherStudentRiskLevel.risk;
  }
}

class TeacherStatsSummaryModel {
  final int totalStudents;
  final int totalAssignments;
  final int totalSubmissions;
  final int pendingToGrade;
  final double? averageGrade;
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
    this.averageGrade,
    required this.highPerformanceCount,
    required this.mediumPerformanceCount,
    required this.riskCount,
    required this.highPerformancePercentage,
    required this.mediumPerformancePercentage,
    required this.riskPercentage,
    required this.students,
  });

  TeacherStatsSummaryModel copyWith({
    int? totalStudents,
    int? totalAssignments,
    int? totalSubmissions,
    int? pendingToGrade,
    double? averageGrade,
    int? highPerformanceCount,
    int? mediumPerformanceCount,
    int? riskCount,
    double? highPerformancePercentage,
    double? mediumPerformancePercentage,
    double? riskPercentage,
    List<TeacherStudentStatsModel>? students,
  }) {
    return TeacherStatsSummaryModel(
      totalStudents: totalStudents ?? this.totalStudents,
      totalAssignments: totalAssignments ?? this.totalAssignments,
      totalSubmissions: totalSubmissions ?? this.totalSubmissions,
      pendingToGrade: pendingToGrade ?? this.pendingToGrade,
      averageGrade: averageGrade ?? this.averageGrade,
      highPerformanceCount: highPerformanceCount ?? this.highPerformanceCount,
      mediumPerformanceCount: mediumPerformanceCount ?? this.mediumPerformanceCount,
      riskCount: riskCount ?? this.riskCount,
      highPerformancePercentage: highPerformancePercentage ?? this.highPerformancePercentage,
      mediumPerformancePercentage: mediumPerformancePercentage ?? this.mediumPerformancePercentage,
      riskPercentage: riskPercentage ?? this.riskPercentage,
      students: students ?? this.students,
    );
  }

  factory TeacherStatsSummaryModel.empty() {
    return TeacherStatsSummaryModel(
      totalStudents: 0,
      totalAssignments: 0,
      totalSubmissions: 0,
      pendingToGrade: 0,
      averageGrade: null,
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
