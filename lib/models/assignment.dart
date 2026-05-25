class AssignmentModel {
  final String id;
  final String courseId;
  final String teacherId;
  final String title;
  final String? description;
  final DateTime? startDate;
  final DateTime dueDate;
  final DateTime createdAt;
  final String type; // 'Tarea', 'Examen', 'Proyecto', etc.
  final double maxGrade;
  final bool requiresFile;
  final bool isGroupAssignment;
  final DateTime? updatedAt;

  final String? fileUrl;
  final int? courseGroupId;
  final String? assignmentType;
  final String priority;

  const AssignmentModel({
    required this.id,
    required this.courseId,
    required this.teacherId,
    required this.title,
    this.description,
    this.startDate,
    required this.dueDate,
    required this.createdAt,
    this.type = 'Tarea',
    this.maxGrade = 5.0,
    this.requiresFile = true,
    this.isGroupAssignment = false,
    this.updatedAt,
    this.fileUrl,
    this.courseGroupId,
    this.assignmentType,
    this.priority = 'medio',
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id']?.toString() ?? '',
      courseId: (json['course_id'] ?? json['courseId'])?.toString() ?? '',
      teacherId: (json['teacher_id'] ?? json['teacherId'])?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      startDate: json['start_date'] != null || json['startDate'] != null
          ? DateTime.tryParse(
              (json['start_date'] ?? json['startDate'])?.toString() ?? '')
          : null,
      dueDate: DateTime.tryParse(
              (json['due_date'] ?? json['dueDate'])?.toString() ?? '') ??
          DateTime.now(),
      createdAt: DateTime.tryParse(
              (json['created_at'] ?? json['createdAt'])?.toString() ?? '') ??
          DateTime.now(),
      type: json['type']?.toString() ?? 'Tarea',
      maxGrade:
          (json['max_grade'] ?? json['maxGrade'] as num?)?.toDouble() ?? 5.0,
      requiresFile: json['requires_file'] == 1 ||
          json['requires_file'] == true ||
          json['requiresFile'] == 1 ||
          json['requiresFile'] == true,
      isGroupAssignment: json['is_group_assignment'] == 1 ||
          json['is_group_assignment'] == true,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      fileUrl: (json['file_url'] ?? json['fileUrl'])?.toString(),
      courseGroupId: json['course_group_id'] != null 
          ? int.tryParse(json['course_group_id'].toString()) 
          : null,
      assignmentType: (json['tipo_asignacion'] ?? json['assignment_type'])?.toString(),
      priority: (json['priority'] ?? json['prioridad'])?.toString() ?? 'medio',
    );
  }

  /// Only includes columns that exist in course_assignments.
  /// id is omitted so Supabase auto-generates the integer PK.
  Map<String, dynamic> toJson() => {
        'course_id': int.tryParse(courseId) ?? courseId,
        'teacher_id': teacherId,
        'title': title,
        'description': description,
        'start_date': startDate?.toIso8601String(),
        'due_date': dueDate.toIso8601String(),
        'max_grade': maxGrade,
        'requires_file': requiresFile,
        'tipo_asignacion': assignmentType,
        'course_group_id': courseGroupId,
        'priority': priority,
      };

  AssignmentModel copyWith({
    String? id,
    String? courseId,
    String? teacherId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? createdAt,
    String? type,
    double? maxGrade,
    bool? requiresFile,
    bool? isGroupAssignment,
    DateTime? updatedAt,
    String? fileUrl,
    int? courseGroupId,
    String? assignmentType,
    String? priority,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      teacherId: teacherId ?? this.teacherId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      maxGrade: maxGrade ?? this.maxGrade,
      requiresFile: requiresFile ?? this.requiresFile,
      isGroupAssignment: isGroupAssignment ?? this.isGroupAssignment,
      updatedAt: updatedAt ?? this.updatedAt,
      fileUrl: fileUrl ?? this.fileUrl,
      courseGroupId: courseGroupId ?? this.courseGroupId,
      assignmentType: assignmentType ?? this.assignmentType,
      priority: priority ?? this.priority,
    );
  }
}
