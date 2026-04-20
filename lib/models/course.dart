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
