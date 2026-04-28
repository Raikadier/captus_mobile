import '../services/local_storage_service.dart';

import '../database/database_service.dart';

class SampleData {
  static Future<void> initializeSampleData() async {
<<<<<<< Updated upstream
    final existingCourses = LocalStorageService.courses;
    if (existingCourses.isNotEmpty) return;
=======
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
>>>>>>> Stashed changes

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

<<<<<<< Updated upstream
=======
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

>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
      {
        'id': 't3',
        'title': 'Proyecto Final - Ingeniería de Software',
        'description':
            'Documentar requisitos y arquitectura del sistema de gestión académica.',
        'priority': 'medium',
        'priority_id': 2,
        'completed': false,
        'due_date':
            DateTime.now().add(const Duration(days: 14)).toIso8601String(),
        'subjectName': 'Ingeniería de Software I',
        'courseId': 'c3',
        'subTasks': [
          {
            'id_SubTask': 'st4',
            'title': 'Diagrama de casos de uso',
            'state': true
          },
          {'id_SubTask': 'st5', 'title': 'Diagrama de clases', 'state': false},
          {'id_SubTask': 'st6', 'title': 'Documento SRS', 'state': false},
        ],
        'created_at':
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      },
      {
        'id': 't4',
        'title': 'Ensayo Historia de la Computación',
        'description':
            'Redactar ensayo de 5 páginas sobre la evolución de los lenguajes de programación.',
        'priority': 'low',
        'priority_id': 3,
        'completed': true,
        'due_date':
            DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'subjectName': 'Sistemas Operativos',
        'courseId': 'c4',
        'subTasks': [],
        'created_at':
            DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      },
      {
        'id': 't5',
        'title': 'Práctica Shell Scripting',
        'description':
            'Crear scripts para automatización de tareas del sistema.',
        'priority': 'medium',
        'priority_id': 2,
        'completed': false,
        'due_date':
            DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        'subjectName': 'Sistemas Operativos',
        'courseId': 'c4',
        'subTasks': [
          {
            'id_SubTask': 'st7',
            'title': 'Script backup automático',
            'state': true
          },
          {
            'id_SubTask': 'st8',
            'title': 'Script limpieza temp',
            'state': false
          },
        ],
        'created_at':
            DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
      },
=======
>>>>>>> Stashed changes
    ];

    for (var t in tasks) {
      await DatabaseService.insert('tasks', t);
    }

    // Default subtasks for t1
    final subtasksT1 = [
      {'id': 'st1', 'taskId': 't1', 'title': 'Investigación teórica', 'completed': 1},
      {'id': 'st2', 'taskId': 't1', 'title': 'Implementación código', 'completed': 0},
      {'id': 'st3', 'taskId': 't1', 'title': 'Documentación', 'completed': 0},
    ];
    for (var st in subtasksT1) {
      await DatabaseService.insert('subtasks', st);
    }
  }

  static Future<void> _initializeSampleCourses() async {
    final courses = [
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
<<<<<<< Updated upstream
        'activities': [
          {
            'id': 'a1',
            'title': 'Taller Árboles Binarios',
            'dueDate':
                DateTime.now().add(const Duration(days: 2)).toIso8601String(),
            'type': 'Tarea',
            'isSubmitted': false,
            'requiresFile': true
          },
          {
            'id': 'a2',
            'title': 'Parcial 2',
            'dueDate':
                DateTime.now().add(const Duration(days: 10)).toIso8601String(),
            'type': 'Examen',
            'isSubmitted': false,
            'requiresFile': false
          },
        ],
=======
        'userId': 'u_student_1',
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
        'activities': [
          {
            'id': 'a3',
            'title': 'Taller Integrales Dobles',
            'dueDate':
                DateTime.now().add(const Duration(days: 3)).toIso8601String(),
            'type': 'Tarea',
            'isSubmitted': false,
            'requiresFile': true
          },
        ],
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
        'activities': [
          {
            'id': 'a4',
            'title': 'Diagrama UML',
            'dueDate':
                DateTime.now().add(const Duration(days: 5)).toIso8601String(),
            'type': 'Proyecto',
            'isSubmitted': false,
            'requiresFile': true
          },
          {
            'id': 'a5',
            'title': 'Caso de Estudio',
            'dueDate':
                DateTime.now().add(const Duration(days: 8)).toIso8601String(),
            'type': 'Ensayo',
            'isSubmitted': false,
            'requiresFile': true
          },
        ],
=======
        'userId': 'u_student_1',
>>>>>>> Stashed changes
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
        'activities': [],
      },
    ];

    for (var c in courses) {
      await DatabaseService.insert('courses', c);
    }
  }

  static Future<void> _initializeSampleEvents() async {
    final events = [
      {
        'id': 'e1',
        'title': 'Parcial Cálculo II',
        'description': 'Capítulos 3 y 4',
        'date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'type': 'exam',
        'colorIndex': 1,
        'courseId': 'c2',
<<<<<<< Updated upstream
      },
      {
        'id': 'e2',
        'title': 'Entrega Proyecto IS',
        'description': 'Documentación completa',
        'date': DateTime.now().add(const Duration(days: 14)).toIso8601String(),
        'type': 'deadline',
        'colorIndex': 2,
        'courseId': 'c3',
      },
      {
        'id': 'e3',
        'title': 'Clase Extra - EDD',
        'description': 'Repaso para el parcial',
        'date': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
        'type': 'class',
        'colorIndex': 0,
        'courseId': 'c1',
=======
        'userId': 'u_student_1',
>>>>>>> Stashed changes
      },
    ];

    for (var e in events) {
      await DatabaseService.insert('events', e);
    }
  }

  static Future<void> _initializeSampleGroups() async {
    final groups = [
      {
        'id': 'g1',
        'name': 'Grupo Proyecto IS',
        'description': 'Equipo para el proyecto final de Ingeniería de Software',
        'memberCount': 4,
<<<<<<< Updated upstream
        'isJoined': true,
        'members': [
          {'id': 'u1', 'name': 'Tú', 'role': 'student'},
          {'id': 'u2', 'name': 'Ana García', 'role': 'student'},
          {'id': 'u3', 'name': 'Carlos Ruiz', 'role': 'student'},
          {'id': 'u4', 'name': 'María López', 'role': 'student'},
        ],
        'createdAt':
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      },
      {
        'id': 'g2',
        'name': 'Club de Algoritmos',
        'description': 'Grupo de estudio para competencias de programación',
        'memberCount': 12,
        'isJoined': false,
        'members': [],
        'createdAt':
            DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
=======
        'isJoined': 1,
        'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'userId': 'u_student_1',
>>>>>>> Stashed changes
      },
    ];

    for (var g in groups) {
      await DatabaseService.insert('groups', g);
    }
  }
}
