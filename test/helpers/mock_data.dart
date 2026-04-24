import 'package:captus_mobile/models/user.dart';
import 'package:captus_mobile/models/course.dart';
import 'package:captus_mobile/models/task.dart';
import 'package:captus_mobile/core/providers/auth_provider.dart';

/// Mock data utilities for testing
class MockData {
  // User mock data
  static const LocalUser mockStudent = LocalUser(
    id: 'student_123',
    email: 'student@unicesar.edu.co',
    name: 'Juan Pérez',
    role: 'student',
    university: 'Universidad Popular del Cesar',
    career: 'Ingeniería de Sistemas',
    semester: 5,
    bio: 'Estudiante apasionado por la tecnología',
    avatarUrl: 'https://example.com/avatar1.jpg',
  );

  static const LocalUser mockTeacher = LocalUser(
    id: 'teacher_456',
    email: 'teacher@unicesar.edu.co',
    name: 'María García',
    role: 'teacher',
    university: 'Universidad Popular del Cesar',
    career: 'Docente',
    semester: 0,
    bio: 'Profesora de Ingeniería de Software',
    avatarUrl: 'https://example.com/avatar2.jpg',
  );

  static const LocalUser mockAdmin = LocalUser(
    id: 'admin_789',
    email: 'admin@unicesar.edu.co',
    name: 'Administrador',
    role: 'admin',
    university: 'Universidad Popular del Cesar',
    career: 'Administración',
    semester: 0,
    bio: 'Administrador del sistema',
    avatarUrl: 'https://example.com/avatar3.jpg',
  );

  // Course mock data
  static List<CourseModel> get mockCourses => [
    CourseModel(
      id: 'course_1',
      name: 'Estructuras de Datos',
      code: 'IS-301',
      teacherName: 'Prof. Carlos Rodríguez',
      colorIndex: 0,
      progress: 0.75,
      pendingActivities: 2,
      activities: [
        ActivityModel(
          id: 'activity_1',
          title: 'Taller Árboles Binarios',
          description: 'Implementar operaciones básicas de árboles binarios',
          dueDate: DateTime.now().add(const Duration(days: 3)),
          type: 'Tarea',
          requiresFile: true,
          isSubmitted: false,
          isGraded: false,
        ),
        ActivityModel(
          id: 'activity_2',
          title: 'Quiz Recursividad',
          description: 'Evaluación sobre conceptos de recursividad',
          dueDate: DateTime.now().add(const Duration(days: 7)),
          type: 'Quiz',
          requiresFile: false,
          isSubmitted: true,
          isGraded: true,
          grade: 85.0,
          feedback: 'Buen desempeño',
        ),
      ],
      description: 'Curso sobre estructuras de datos fundamentales',
      schedule: 'Lunes y Miércoles 10:00-12:00',
    ),
    CourseModel(
      id: 'course_2',
      name: 'Cálculo II',
      code: 'MA-201',
      teacherName: 'Prof. Ana Martínez',
      colorIndex: 1,
      progress: 0.60,
      pendingActivities: 3,
      activities: [
        ActivityModel(
          id: 'activity_3',
          title: 'Parcial II',
          description: 'Evaluación de integración y derivadas',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          type: 'Examen',
          requiresFile: false,
          isSubmitted: false,
          isGraded: false,
        ),
      ],
      description: 'Curso de cálculo diferencial e integral',
      schedule: 'Martes y Jueves 14:00-16:00',
    ),
    CourseModel(
      id: 'course_3',
      name: 'Ingeniería de Software I',
      code: 'IS-401',
      teacherName: 'Prof. Luis López',
      colorIndex: 2,
      progress: 0.85,
      pendingActivities: 1,
      activities: [
        ActivityModel(
          id: 'activity_4',
          title: 'Proyecto Final',
          description: 'Desarrollo de aplicación móvil',
          dueDate: DateTime.now().add(const Duration(days: 14)),
          type: 'Proyecto',
          requiresFile: true,
          isSubmitted: false,
          isGraded: false,
        ),
      ],
      description: 'Fundamentos de ingeniería de software',
      schedule: 'Viernes 08:00-12:00',
    ),
    CourseModel(
      id: 'course_4',
      name: 'Sistemas Operativos',
      code: 'IS-302',
      teacherName: 'Prof. Diana Castro',
      colorIndex: 3,
      progress: 0.45,
      pendingActivities: 4,
      activities: [
        ActivityModel(
          id: 'activity_5',
          title: 'Lab Procesos',
          description: 'Implementación de gestión de procesos',
          dueDate: DateTime.now().add(const Duration(days: 2)),
          type: 'Laboratorio',
          requiresFile: true,
          isSubmitted: true,
          isGraded: true,
          grade: 90.0,
        ),
      ],
      description: 'Conceptos fundamentales de sistemas operativos',
      schedule: 'Lunes y Miércoles 16:00-18:00',
    ),
  ];

  // Task mock data
  static List<TaskModel> get mockTasks => [
    TaskModel(
      id: 'task_1',
      title: 'Entregar Taller Árboles',
      description: 'Completar el taller de árboles binarios para Estructuras de Datos',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      priority: TaskPriority.high,
      status: TaskStatus.pending,
      courseId: 'course_1',
      courseName: 'Estructuras de Datos',
    ),
    TaskModel(
      id: 'task_2',
      title: 'Estudiar para Parcial Cálculo',
      description: 'Repasar temas de integración para el parcial II',
      dueDate: DateTime.now().add(const Duration(days: 4)),
      priority: TaskPriority.high,
      status: TaskStatus.in_progress,
      courseId: 'course_2',
      courseName: 'Cálculo II',
    ),
    TaskModel(
      id: 'task_3',
      title: 'Reunión de Proyecto',
      description: 'Reunión con el equipo para el proyecto de Ingeniería de Software',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      priority: TaskPriority.medium,
      status: TaskStatus.pending,
      courseId: 'course_3',
      courseName: 'Ingeniería de Software I',
    ),
    TaskModel(
      id: 'task_4',
      title: 'Laboratorio Sistemas Operativos',
      description: 'Completar el laboratorio de gestión de memoria',
      dueDate: DateTime.now().subtract(const Duration(days: 1)),
      priority: TaskPriority.low,
      status: TaskStatus.completed,
      courseId: 'course_4',
      courseName: 'Sistemas Operativos',
    ),
    TaskModel(
      id: 'task_5',
      title: 'Actualizar Perfil',
      description: 'Actualizar información académica en el perfil',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      priority: TaskPriority.low,
      status: TaskStatus.pending,
      courseId: null,
      courseName: null,
    ),
  ];

  // Notification mock data
  static List<Map<String, dynamic>> get mockNotifications => [
    {
      'id': 'notif_1',
      'title': 'Nueva tarea asignada',
      'body': 'Se ha asignado una nueva tarea en Estructuras de Datos',
      'type': 'task',
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
      'read': false,
      'data': {'courseId': 'course_1', 'taskId': 'task_1'},
    },
    {
      'id': 'notif_2',
      'title': 'Recordatorio de examen',
      'body': 'Recuerda que tienes un examen de Cálculo II en 3 días',
      'type': 'reminder',
      'createdAt': DateTime.now().subtract(const Duration(hours: 5)),
      'read': false,
      'data': {'courseId': 'course_2', 'examId': 'exam_1'},
    },
    {
      'id': 'notif_3',
      'title': 'Calificación publicada',
      'body': 'Tu calificación del laboratorio de Sistemas Operativos está disponible',
      'type': 'grade',
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
      'read': true,
      'data': {'courseId': 'course_4', 'grade': 90.0},
    },
    {
      'id': 'notif_4',
      'title': 'Mensaje del profesor',
      'body': 'Prof. Luis López ha enviado un mensaje sobre el proyecto final',
      'type': 'message',
      'createdAt': DateTime.now().subtract(const Duration(days: 2)),
      'read': true,
      'data': {'courseId': 'course_3', 'teacherId': 'teacher_1'},
    },
  ];

  // Event mock data
  static List<Map<String, dynamic>> get mockEvents => [
    {
      'id': 'event_1',
      'title': 'Parcial Cálculo II',
      'description': 'Segundo parcial de Cálculo II',
      'startTime': DateTime.now().add(const Duration(days: 5, hours: 14)),
      'endTime': DateTime.now().add(const Duration(days: 5, hours: 16)),
      'location': 'Aula 201',
      'type': 'exam',
      'courseId': 'course_2',
    },
    {
      'id': 'event_2',
      'title': 'Reunión de Proyecto',
      'description:': 'Reunión semanal del equipo de proyecto',
      'startTime': DateTime.now().add(const Duration(days: 1, hours: 10)),
      'endTime': DateTime.now().add(const Duration(days: 1, hours: 11)),
      'location': 'Sala de reuniones',
      'type': 'meeting',
      'courseId': 'course_3',
    },
    {
      'id': 'event_3',
      'title': 'Tutoría Estructuras de Datos',
      'description': 'Tutoría extra para resolver dudas',
      'startTime': DateTime.now().add(const Duration(days: 3, hours: 16)),
      'endTime': DateTime.now().add(const Duration(days: 3, hours: 17)),
      'location': 'Aula 105',
      'type': 'tutorial',
      'courseId': 'course_1',
    },
  ];

  // Group mock data
  static List<Map<String, dynamic>> get mockGroups => [
    {
      'id': 'group_1',
      'name': 'Grupo de Estudio IS-301',
      'description': 'Grupo para estudiar juntos Estructuras de Datos',
      'courseId': 'course_1',
      'memberCount': 5,
      'isOwner': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
    },
    {
      'id': 'group_2',
      'name': 'Proyecto Software',
      'description': 'Equipo para el proyecto final de Ingeniería de Software',
      'courseId': 'course_3',
      'memberCount': 4,
      'isOwner': false,
      'createdAt': DateTime.now().subtract(const Duration(days: 15)),
    },
  ];

  // Statistics mock data
  static Map<String, dynamic> get mockStatistics => {
    'totalCourses': 4,
    'completedCourses': 0,
    'pendingTasks': 3,
    'completedTasks': 1,
    'averageProgress': 0.66,
    'totalGrades': 2,
    'averageGrade': 87.5,
    'attendanceRate': 0.92,
    'studyHours': 24,
  };

  // API response mock data
  static Map<String, dynamic> get mockLoginResponse => {
    'success': true,
    'data': {
      'user': mockStudent.toJson(),
      'token': 'mock_jwt_token_12345',
      'refreshToken': 'mock_refresh_token_67890',
    },
  };

  static Map<String, dynamic> get mockCoursesResponse => {
    'success': true,
    'data': mockCourses.map((course) => course.toJson()).toList(),
  };

  static Map<String, dynamic> get mockTasksResponse => {
    'success': true,
    'data': mockTasks.map((task) => task.toJson()).toList(),
  };

  static Map<String, dynamic> get mockNotificationsResponse => {
    'success': true,
    'data': mockNotifications,
  };

  static Map<String, dynamic> get mockErrorResponse => {
    'success': false,
    'error': 'Authentication failed',
    'message': 'Invalid credentials provided',
  };

  // Helper methods
  static LocalUser getUserByRole(String role) {
    switch (role) {
      case 'student':
        return mockStudent;
      case 'teacher':
        return mockTeacher;
      case 'admin':
        return mockAdmin;
      default:
        return mockStudent;
    }
  }

  static CourseModel getCourseById(String id) {
    return mockCourses.firstWhere((course) => course.id == id);
  }

  static TaskModel getTaskById(String id) {
    return mockTasks.firstWhere((task) => task.id == id);
  }

  static List<TaskModel> getTasksByStatus(TaskStatus status) {
    return mockTasks.where((task) => task.status == status).toList();
  }

  static List<TaskModel> getTasksByPriority(TaskPriority priority) {
    return mockTasks.where((task) => task.priority == priority).toList();
  }

  static List<TaskModel> getTasksByCourse(String courseId) {
    return mockTasks.where((task) => task.courseId == courseId).toList();
  }

  static List<Map<String, dynamic>> getUnreadNotifications() {
    return mockNotifications.where((notif) => !notif['read']).toList();
  }

  static List<Map<String, dynamic>> getNotificationsByType(String type) {
    return mockNotifications.where((notif) => notif['type'] == type).toList();
  }

  static List<Map<String, dynamic>> getEventsByDateRange(DateTime start, DateTime end) {
    return mockEvents.where((event) {
      final eventStart = event['startTime'] as DateTime;
      return eventStart.isAfter(start) && eventStart.isBefore(end);
    }).toList();
  }

  static List<Map<String, dynamic>> getEventsByCourse(String courseId) {
    return mockEvents.where((event) => event['courseId'] == courseId).toList();
  }

  // Test scenarios
  static List<LocalUser> get allMockUsers => [mockStudent, mockTeacher, mockAdmin];

  static List<CourseModel> get emptyCoursesList => [];

  static List<TaskModel> get emptyTasksList => [];

  static List<Map<String, dynamic>> get emptyNotificationsList => [];

  static List<Map<String, dynamic>> get emptyEventsList => [];

  // Error scenarios
  static Map<String, dynamic> get networkErrorResponse => {
    'success': false,
    'error': 'Network error',
    'message': 'Unable to connect to server',
  };

  static Map<String, dynamic> get serverErrorResponse => {
    'success': false,
    'error': 'Server error',
    'message': 'Internal server error occurred',
  };

  static Map<String, dynamic> get unauthorizedResponse => {
    'success': false,
    'error': 'Unauthorized',
    'message': 'Authentication required',
  };

  static Map<String, dynamic> get forbiddenResponse => {
    'success': false,
    'error': 'Forbidden',
    'message': 'Access denied',
  };

  static Map<String, dynamic> get notFoundResponse => {
    'success': false,
    'error': 'Not found',
    'message': 'Resource not found',
  };
}
