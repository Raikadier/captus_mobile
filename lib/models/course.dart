class ActivityModel {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final String type;
  final bool requiresFile;
  final bool isSubmitted;
  final bool isGraded;
  final double? grade;
  final String? feedback;

  const ActivityModel({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.type,
    this.requiresFile = true,
    this.isSubmitted = false,
    this.isGraded = false,
    this.grade,
    this.feedback,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      dueDate: DateTime.tryParse(json['dueDate']?.toString() ?? '') ??
          DateTime.now(),
      type: json['type']?.toString() ?? '',
      requiresFile: json['requiresFile'] == true || json['requiresFile'] == 1,
      isSubmitted: json['isSubmitted'] == true || json['isSubmitted'] == 1,
      isGraded: json['isGraded'] == true || json['isGraded'] == 1,
      grade: (json['grade'] as num?)?.toDouble(),
      feedback: json['feedback']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
        'type': type,
        'requiresFile': requiresFile ? 1 : 0,
        'isSubmitted': isSubmitted ? 1 : 0,
        'isGraded': isGraded ? 1 : 0,
        'grade': grade,
        'feedback': feedback,
      };
}

class CourseModel {
  final String id;
  final String name;
  final String code;
  final String teacherName;
  final int colorIndex;
  final double progress;
  final int pendingActivities;
  final List<ActivityModel> activities;
  final String? description;
  final String? schedule;

  const CourseModel({
    required this.id,
    required this.name,
    required this.code,
    required this.teacherName,
    required this.colorIndex,
    this.progress = 0.0,
    this.pendingActivities = 0,
    this.activities = const [],
    this.description,
    this.schedule,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final activitiesRaw = json['activities'];
    List<ActivityModel> activities = [];
    if (activitiesRaw is List) {
      activities = activitiesRaw
          .map((a) => ActivityModel.fromJson(a as Map<String, dynamic>))
          .toList();
    }

    return CourseModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      teacherName: json['teacherName']?.toString() ?? '',
      colorIndex: (json['colorIndex'] as num?)?.toInt() ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      pendingActivities: (json['pendingActivities'] as num?)?.toInt() ?? 0,
      activities: activities,
      description: json['description']?.toString(),
      schedule: json['schedule']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'teacherName': teacherName,
        'colorIndex': colorIndex,
        'progress': progress,
        'pendingActivities': pendingActivities,
        'description': description,
        'schedule': schedule,
      };

  static List<CourseModel> get mockList => [
        CourseModel(
          id: 'c1',
          name: 'Estructuras de Datos',
          code: 'IS-301',
          teacherName: 'Prof. García',
          colorIndex: 0,
          progress: 0.65,
          pendingActivities: 2,
          activities: [
            ActivityModel(
              id: 'a1',
              title: 'Taller Árboles Binarios',
              dueDate: DateTime.now().add(const Duration(days: 1)),
              type: 'Tarea',
              isSubmitted: false,
            ),
            ActivityModel(
              id: 'a2',
              title: 'Parcial 2',
              dueDate: DateTime.now().add(const Duration(days: 10)),
              type: 'Examen',
              isSubmitted: false,
            ),
          ],
        ),
        CourseModel(
          id: 'c2',
          name: 'Cálculo II',
          code: 'MA-201',
          teacherName: 'Prof. Martínez',
          colorIndex: 1,
          progress: 0.40,
          pendingActivities: 1,
        ),
        CourseModel(
          id: 'c3',
          name: 'Ingeniería de Software I',
          code: 'IS-401',
          teacherName: 'Prof. López',
          colorIndex: 2,
          progress: 0.80,
          pendingActivities: 3,
        ),
        CourseModel(
          id: 'c4',
          name: 'Sistemas Operativos',
          code: 'IS-302',
          teacherName: 'Prof. Rodríguez',
          colorIndex: 3,
          progress: 0.55,
          pendingActivities: 0,
        ),
      ];
}
