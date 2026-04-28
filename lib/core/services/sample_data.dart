import '../services/local_storage_service.dart';
import '../database/database_service.dart';

class SampleData {
  static Future<void> initializeSampleData() async {
    // 1. Users
    final existingUsers = await DatabaseService.query('users');
    if (existingUsers.isEmpty) {
      await _initializeDefaultUsers();
    }

    // 2. Courses
    final existingCourses = await DatabaseService.query('courses');
    if (existingCourses.isEmpty) {
      await _initializeSampleCourses();
    }

    // 3. Tasks
    final existingTasks = await DatabaseService.query('tasks');
    if (existingTasks.isEmpty) {
      await _initializeSampleTasks();
    }

    // 4. Events
    final existingEvents = await DatabaseService.query('events');
    if (existingEvents.isEmpty) {
      await _initializeSampleEvents();
    }

    // 5. Groups
    final existingGroups = await DatabaseService.query('groups');
    if (existingGroups.isEmpty) {
      await _initializeSampleGroups();
    }
  }

  static Future<void> _initializeDefaultUsers() async {
    final defaultUsers = [
      {
        'id': 'u_student_1',
        'email': 'estudiante@captus.app',
        'name': 'David Barceló',
        'password': '12345678',
        'role': 'student',
        'university': 'Universidad Popular del Cesar',
        'career': 'Ingeniería de Sistemas',
        'semester': 5,
      },
      {
        'id': 'u_teacher_1',
        'email': 'docente@captus.app',
        'name': 'Prof. García',
        'password': '12345678',
        'role': 'teacher',
        'university': 'Universidad Popular del Cesar',
        'career': 'Docente',
        'semester': 0,
      },
    ];

    for (var u in defaultUsers) {
      await DatabaseService.insert('users', u);
    }
  }

  static Future<void> _initializeSampleTasks() async {
    final tasks = [
      {
        'id': 't1',
        'title': 'Taller Árboles Binarios',
        'description':
            'Implementar algoritmos de inserción, búsqueda y eliminación en árboles binarios de búsqueda.',
        'priority': 'high',
        'status': 'pending',
        'completed': 0,
        'dueDate':
            DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        'subjectName': 'Estructuras de Datos',
        'courseId': 'c1',
        'userId': 'u_student_1',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      },
      {
        'id': 't2',
        'title': 'Parcial 2 - Cálculo II',
        'description': 'Capítulo 3: Integrales múltiples y aplicaciones.',
        'priority': 'high',
        'status': 'pending',
        'completed': 0,
        'dueDate':
            DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'subjectName': 'Cálculo II',
        'courseId': 'c2',
        'userId': 'u_student_1',
        'createdAt':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      },
    ];

    for (var t in tasks) {
      await DatabaseService.insert('tasks', t as Map<String, dynamic>);
    }

    // Default subtasks for t1
    final subtasksT1 = [
      {
        'id': 'st1',
        'taskId': 't1',
        'title': 'Investigación teórica',
        'completed': 1
      },
      {
        'id': 'st2',
        'taskId': 't1',
        'title': 'Implementación código',
        'completed': 0
      },
      {'id': 'st3', 'taskId': 't1', 'title': 'Documentación', 'completed': 0},
    ];
    for (var st in subtasksT1) {
      await DatabaseService.insert('subtasks', st);
    }
  }

  static Future<void> _initializeSampleCourses() async {
    final courses = <Map<String, dynamic>>[
      {
        'id': 'c1',
        'name': 'Estructuras de Datos',
        'code': 'IS-301',
        'teacherName': 'Prof. García',
        'colorIndex': 0,
        'progress': 0.65,
        'pendingActivities': 2,
        'description': 'Algoritmos y estructuras de datos fundamentales.',
        'schedule': 'Lun/Mié 10:00-12:00',
        'userId': 'u_student_1',
      },
      {
        'id': 'c2',
        'name': 'Cálculo II',
        'code': 'MA-201',
        'teacherName': 'Prof. Martínez',
        'colorIndex': 1,
        'progress': 0.40,
        'pendingActivities': 1,
        'description': 'Cálculo integral multivariable.',
        'schedule': 'Mar/Jue 14:00-16:00',
        'userId': 'u_student_1',
      },
      {
        'id': 'c3',
        'name': 'Ingeniería de Software I',
        'code': 'IS-401',
        'teacherName': 'Prof. López',
        'colorIndex': 2,
        'progress': 0.80,
        'pendingActivities': 3,
        'description': 'Metodologías y proceso de desarrollo de software.',
        'schedule': 'Lun/Mié/Vie 08:00-10:00',
        'userId': 'u_student_1',
      },
      {
        'id': 'c4',
        'name': 'Sistemas Operativos',
        'code': 'IS-302',
        'teacherName': 'Prof. Rodríguez',
        'colorIndex': 3,
        'progress': 0.55,
        'pendingActivities': 0,
        'description': 'Fundamentos de sistemas operativos y administración.',
        'schedule': 'Mar/Jue 16:00-18:00',
        'userId': 'u_student_1',
      },
    ];

    for (var c in courses) {
      await DatabaseService.insert('courses', c);
    }
  }

  static Future<void> _initializeSampleEvents() async {
    final events = <Map<String, dynamic>>[
      {
        'id': 'e1',
        'title': 'Parcial Cálculo II',
        'description': 'Capítulos 3 y 4',
        'date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'type': 'exam',
        'colorIndex': 1,
        'courseId': 'c2',
        'userId': 'u_student_1',
      },
    ];

    for (var e in events) {
      await DatabaseService.insert('events', e);
    }
  }

  static Future<void> _initializeSampleGroups() async {
    final groups = <Map<String, dynamic>>[
      {
        'id': 'g1',
        'name': 'Grupo Proyecto IS',
        'description':
            'Equipo para el proyecto final de Ingeniería de Software',
        'memberCount': 4,
        'isJoined': 1,
        'createdAt':
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'userId': 'u_student_1',
      },
    ];

    for (var g in groups) {
      await DatabaseService.insert('groups', g);
    }
  }
}
