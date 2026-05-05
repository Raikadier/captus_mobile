class SubmissionModel {
  final String id;
  final String assignmentId;
  final String studentId;
  final String? fileUrl;
  final String? content;
  final DateTime submittedAt;
  final String status; // 'pending', 'submitted', 'graded'
  final double? grade;
  final String? feedback;
  final String? groupId;
  final bool graded;

  const SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    this.fileUrl,
    this.content,
    required this.submittedAt,
    this.status = 'submitted',
    this.grade,
    this.feedback,
    this.groupId,
    this.graded = false,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id']?.toString() ?? '',
      assignmentId:
          (json['assignment_id'] ?? json['assignmentId'])?.toString() ?? '',
      studentId: (json['student_id'] ?? json['studentId'])?.toString() ?? '',
      fileUrl: (json['file_url'] ?? json['fileUrl'])?.toString(),
      content: json['content']?.toString(),
      submittedAt: DateTime.tryParse(
              (json['submitted_at'] ?? json['submittedAt'])?.toString() ??
                  '') ??
          DateTime.now(),
      status: (json['graded'] == true || json['graded'] == 1)
          ? 'graded'
          : (json['status']?.toString() ?? 'submitted'),
      grade: (json['grade'] as num?)?.toDouble(),
      feedback: json['feedback']?.toString(),
      groupId: (json['group_id'] ?? json['groupId'])?.toString(),
      graded: json['graded'] == true || json['graded'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'assignment_id': assignmentId,
        'student_id': studentId,
        'file_url': fileUrl,
        'content': content,
        'submitted_at': submittedAt.toIso8601String(),
        // 'status': status, // Reemplazado por graded u opcional
        'grade': grade,
        'feedback': feedback,
        'group_id': groupId,
        'graded': graded || status == 'graded',
      };

  SubmissionModel copyWith({
    String? id,
    String? assignmentId,
    String? studentId,
    String? fileUrl,
    String? content,
    DateTime? submittedAt,
    String? status,
    double? grade,
    String? feedback,
    String? groupId,
    bool? graded,
  }) {
    return SubmissionModel(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      studentId: studentId ?? this.studentId,
      fileUrl: fileUrl ?? this.fileUrl,
      content: content ?? this.content,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      grade: grade ?? this.grade,
      feedback: feedback ?? this.feedback,
      groupId: groupId ?? this.groupId,
      graded: graded ?? this.graded,
    );
  }
}
