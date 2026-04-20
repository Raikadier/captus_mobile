enum TaskPriority { high, medium, low }

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

  SubTask copyWith({bool? isCompleted}) =>
      SubTask(id: id, title: title, isCompleted: isCompleted ?? this.isCompleted);
}

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final String? courseId;
  final String? courseName;
  final String? groupId;
  final List<SubTask> subtasks;
  final List<String> attachments;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.dueDate,
    this.courseId,
    this.courseName,
    this.groupId,
    this.subtasks = const [],
    this.attachments = const [],
    required this.createdAt,
  });

  int get completedSubtasks => subtasks.where((s) => s.isCompleted).length;

  bool get isOverdue =>
      dueDate != null &&
      dueDate!.isBefore(DateTime.now()) &&
      status != TaskStatus.completed;

  Duration? get timeUntilDue =>
      dueDate != null ? dueDate!.difference(DateTime.now()) : null;

  static List<TaskModel> get mockList => [
        TaskModel(
          id: '1',
          title: 'Entrega Estructuras de Datos',
          priority: TaskPriority.high,
          status: TaskStatus.pending,
          dueDate: DateTime.now().add(const Duration(hours: 18)),
          courseName: 'Estructuras de Datos',
          subtasks: [
            const SubTask(id: 's1', title: 'Implementar árbol AVL', isCompleted: true),
            const SubTask(id: 's2', title: 'Documentar código'),
            const SubTask(id: 's3', title: 'Pruebas unitarias'),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        TaskModel(
          id: '2',
          title: 'Parcial Cálculo II',
          priority: TaskPriority.high,
          status: TaskStatus.pending,
          dueDate: DateTime.now().add(const Duration(days: 2)),
          courseName: 'Cálculo II',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        TaskModel(
          id: '3',
          title: 'Informe de Software I',
          priority: TaskPriority.medium,
          status: TaskStatus.inProgress,
          dueDate: DateTime.now().add(const Duration(days: 5)),
          courseName: 'Ingeniería de Software I',
          subtasks: [
            const SubTask(id: 's4', title: 'Introducción', isCompleted: true),
            const SubTask(id: 's5', title: 'Análisis de requerimientos', isCompleted: true),
            const SubTask(id: 's6', title: 'Conclusiones'),
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        TaskModel(
          id: '4',
          title: 'Lectura Sistemas Operativos Cap. 5',
          priority: TaskPriority.low,
          status: TaskStatus.pending,
          dueDate: DateTime.now().add(const Duration(days: 7)),
          courseName: 'Sistemas Operativos',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
}
