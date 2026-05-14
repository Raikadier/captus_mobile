enum TaskPriority { high, medium, low }

extension TaskPriorityX on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.high:
        return 'Alta';
      case TaskPriority.medium:
        return 'Media';
      case TaskPriority.low:
        return 'Baja';
    }
  }

  /// Maps backend priority_id (1=high,2=medium,3=low) or name string
  static TaskPriority fromBackend(dynamic value) {
    if (value is int) {
      switch (value) {
        case 1:
          return TaskPriority.high;
        case 2:
          return TaskPriority.medium;
        default:
          return TaskPriority.low;
      }
    }
    final s = value?.toString().toLowerCase() ?? '';
    if (s.contains('alta') || s.contains('high')) return TaskPriority.high;
    if (s.contains('media') || s.contains('medium')) return TaskPriority.medium;
    return TaskPriority.low;
  }
}

enum TaskStatus { pending, inProgress, completed, overdue }

class SubTask {
  final String id;
  final String title;
  final bool isCompleted;

  const SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  SubTask copyWith({bool? isCompleted}) => SubTask(
      id: id, title: title, isCompleted: isCompleted ?? this.isCompleted);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'completed': isCompleted,
      };

  factory SubTask.fromJson(Map<String, dynamic> json) => SubTask(
        id: json['id_SubTask']?.toString() ?? json['id']?.toString() ?? '',
        title: json['title'] as String? ?? '',
        isCompleted: json['state'] as bool? ?? false,
      );
}

class TaskModel {
  final int? id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final String? courseId;
  final String? courseName;
  final String? subjectName;
  final String? groupId;
  final List<SubTask> subtasks;
  final List<String> attachments;
  final DateTime createdAt;
  final bool completed;
  final int? categoryId;
  final String? categoryName;
  final int? parentTaskId;

  const TaskModel({
    this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.dueDate,
    this.courseId,
    this.courseName,
    this.subjectName,
    this.groupId,
    this.subtasks = const [],
    this.attachments = const [],
    required this.createdAt,
    this.completed = false,
    this.categoryId,
    this.categoryName,
    this.parentTaskId,
  });

  int get completedSubtasks => subtasks.where((s) => s.isCompleted).length;

  bool get isOverdue =>
      dueDate != null &&
      dueDate!.isBefore(DateTime.now()) &&
      status != TaskStatus.completed;

  Duration? get timeUntilDue =>
      dueDate != null ? dueDate!.difference(DateTime.now()) : null;

  /// Display name: courseName or subjectName, whichever is available
  String? get contextLabel => courseName ?? subjectName;

  // ── JSON deserialization ──────────────────────────────────────────────────

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final bool isCompleted =
        (json['completed'] as bool?) ?? (json['state'] as bool?) ?? false;

    DateTime? dueDate;
    final rawDue = json['due_date'] ?? json['endDate'];
    if (rawDue != null) {
      dueDate = DateTime.tryParse(rawDue.toString());
    }

    TaskStatus status;
    if (isCompleted) {
      status = TaskStatus.completed;
    } else if (dueDate != null && dueDate.isBefore(DateTime.now())) {
      status = TaskStatus.overdue;
    } else {
      status = TaskStatus.pending;
    }

    final rawSubtasks = json['subTasks'] ?? json['subtasks'] ?? [];
    final subtasks = (rawSubtasks as List)
        .map((s) => SubTask.fromJson(s as Map<String, dynamic>))
        .toList();

    final categoryData = json['category'] as Map<String, dynamic>?;

    return TaskModel(
      id: json['id'] as int? ?? int.tryParse(json['id']?.toString() ?? ''),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      priority: TaskPriorityX.fromBackend(
        json['priority_id'] ?? json['priority']?['id'] ?? json['priority'],
      ),
      status: status,
      dueDate: dueDate,
      subjectName:
          json['subject']?['name'] as String? ?? json['subjectName'] as String?,
      subtasks: subtasks,
      createdAt: DateTime.tryParse(
              (json['created_at'] ?? json['creationDate'] ?? '').toString()) ??
          DateTime.now(),
      completed: isCompleted,
      categoryId: json['category_id'] as int?,
      categoryName: categoryData?['name'] as String? ?? json['category_name'] as String?,
      parentTaskId: json['parent_task_id'] as int?,
    );
  }

  TaskModel copyWith({
    bool? completed,
    TaskStatus? status,
    int? categoryId,
    String? categoryName,
    int? parentTaskId,
    List<SubTask>? subtasks,
  }) =>
      TaskModel(
        id: id,
        title: title,
        description: description,
        priority: priority,
        status: status ?? this.status,
        dueDate: dueDate,
        courseId: courseId,
        courseName: courseName,
        subjectName: subjectName,
        groupId: groupId,
        subtasks: subtasks ?? this.subtasks,
        attachments: attachments,
        createdAt: createdAt,
        completed: completed ?? this.completed,
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
        parentTaskId: parentTaskId ?? this.parentTaskId,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'priority': priority.index + 1,
        'priority_id': priority.index + 1,
        'status': status.name,
        'due_date': dueDate?.toIso8601String(),
        'courseId': courseId,
        'courseName': courseName,
        'subjectName': subjectName,
        'groupId': groupId,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
        'attachments': attachments,
        'created_at': createdAt.toIso8601String(),
        'completed': completed,
        'category_id': categoryId,
        'categoryName': categoryName,
        'parent_task_id': parentTaskId,
      };

  /// Temporary stub — screens that still reference mockList compile without
  /// errors while they are being migrated to provider-based data fetching.
  static List<TaskModel> get mockList => const [];
}
