class AssignmentTargetModel {
  final String id;
  final String assignmentId;
  final String targetType; // 'group' or 'student'
  final String targetId;

  const AssignmentTargetModel({
    required this.id,
    required this.assignmentId,
    required this.targetType,
    required this.targetId,
  });

  factory AssignmentTargetModel.fromJson(Map<String, dynamic> json) {
    return AssignmentTargetModel(
      id: json['id']?.toString() ?? '',
      assignmentId:
          (json['assignment_id'] ?? json['assignmentId'])?.toString() ?? '',
      targetType: (json['target_type'] ?? json['targetType'])?.toString() ?? '',
      targetId: (json['target_id'] ?? json['targetId'])?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'assignment_id': assignmentId,
        'target_type': targetType,
        'target_id': targetId,
      };
}
