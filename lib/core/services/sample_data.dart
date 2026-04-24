import '../services/local_storage_service.dart';

class SampleData {
  static Future<void> initializeSampleData() async {
    await _initializeDefaultUsers();

    final existingCourses = LocalStorageService.courses;
    if (existingCourses.isNotEmpty) return;

    await _initializeSampleTasks();
    await _initializeSampleCourses();
    await _initializeSampleEvents();
    await _initializeSampleGroups();
  }

  // ── Usuarios por defecto ──────────────────────────────────────────────────
  static Future<void> _initializeDefaultUsers() async {
    final existing = LocalStorageService.users;
    if (existing.isNotEmpty) return;

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

    await LocalStorageService.setList(
        LocalStorageService.usersKey, defaultUsers);
  }

  // ── Tareas ────────────────────────────────────────────────────────────────
  static Future<void> _initializeSampleTasks() async {
    final tasks = [
      {
        'id': 't1',
        'title': 'Taller Árboles Binarios',
        'description':
            'Implementar algoritmos de inserción, búsqueda y eliminación en árboles binarios de búsqueda.',
        'priority': 'high',
        'priority_id': 1,
        'completed': false,
        'due_date':
            DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        'subjectName': 'Estructuras de Datos',
        'courseId': 'c1',
        'subTasks': [
          {
            'id_SubTask': 'st1',
            'title': 'Investigación teórica',
            'state': true
          },
          {
            'id_SubTask': 'st2',
            'title': 'Implementación código',
            'state': false
          },
          {'id_SubTask': 'st3', 'title': 'Documentación', 'state': false},
        ],
        'created_at':
            DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      },
      {
        'id': 't2',
        'title': 'Parcial 2 - Cálculo II',
        'description': 'Capítulo 3: Integrales múltiples y aplicaciones.',
        'priority': 'high',
        'priority_id': 1,
        'completed': false,
        'due_date':
            DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'subjectName': 'Cálculo II',
        'courseId': 'c2',
        'subTasks': [],
        'created_at':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      },
      {
        'id': 't3',
        'title': 'Proyecto Final - Ingeniería de Software',
        'description': 'Documentar requisitos y arquitectura del sistema.',
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
    ];
    await LocalStorageService.setList(LocalStorageService.tasksKey, tasks);
  }

  // ── Cursos ────────────────────────────────────────────────────────────────
  static Future<void> _initializeSampleCourses() async {
    final courses = [
      {
        'id': 'c1',
        'name': 'Estructuras de Datos',
        'code': 'IS-301',
        'teacherName': 'Prof. García',
        'teacherId': 'u_teacher_1',
        'colorIndex': 0,
        'progress': 0.65,
        'pendingActivities': 5,
        'studentCount': 42,
        'description': 'Algoritmos y estructuras de datos fundamentales.',
        'schedule': 'Lun/Mié 10:00-12:00',
        'activities': [
          {
            'id': 'a1',
            'title': 'Taller Árboles Binarios',
            'dueDate':
                DateTime.now().add(const Duration(days: 2)).toIso8601String(),
            'type': 'Tarea',
            'isSubmitted': false,
            'requiresFile': true,
            'submissionCount': 37,
          },
          {
            'id': 'a2',
            'title': 'Parcial 2',
            'dueDate':
                DateTime.now().add(const Duration(days: 10)).toIso8601String(),
            'type': 'Examen',
            'isSubmitted': false,
            'requiresFile': false,
            'submissionCount': 0,
          },
        ],
      },
      {
        'id': 'c2',
        'name': 'Cálculo II',
        'code': 'MA-201',
        'teacherName': 'Prof. García',
        'teacherId': 'u_teacher_1',
        'colorIndex': 1,
        'progress': 0.40,
        'pendingActivities': 12,
        'studentCount': 38,
        'description': 'Cálculo integral multivariable.',
        'schedule': 'Mar/Jue 14:00-16:00',
        'activities': [
          {
            'id': 'a3',
            'title': 'Taller Integrales Dobles',
            'dueDate':
                DateTime.now().add(const Duration(days: 3)).toIso8601String(),
            'type': 'Tarea',
            'isSubmitted': false,
            'requiresFile': true,
            'submissionCount': 26,
          },
        ],
      },
      {
        'id': 'c3',
        'name': 'Taller Algoritmos',
        'code': 'IS-401',
        'teacherName': 'Prof. García',
        'teacherId': 'u_teacher_1',
        'colorIndex': 2,
        'progress': 0.80,
        'pendingActivities': 8,
        'studentCount': 44,
        'description': 'Diseño y análisis de algoritmos.',
        'schedule': 'Vie 08:00-12:00',
        'activities': [
          {
            'id': 'a4',
            'title': 'Algoritmos de Ordenamiento',
            'dueDate':
                DateTime.now().add(const Duration(days: 5)).toIso8601String(),
            'type': 'Tarea',
            'isSubmitted': false,
            'requiresFile': true,
            'submissionCount': 36,
          },
        ],
      },
    ];
    await LocalStorageService.setList(LocalStorageService.coursesKey, courses);
  }

  // ── Eventos ───────────────────────────────────────────────────────────────
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
      },
      {
        'id': 'e2',
        'title': 'Entrega Taller Algoritmos',
        'description': 'Algoritmos de ordenamiento',
        'date': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
        'type': 'deadline',
        'colorIndex': 2,
        'courseId': 'c3',
      },
      {
        'id': 'e3',
        'title': 'Clase Extra - EDD',
        'description': 'Repaso para el parcial',
        'date': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        'type': 'class',
        'colorIndex': 0,
        'courseId': 'c1',
      },
    ];
    await LocalStorageService.setList(LocalStorageService.eventsKey, events);
  }

  // ── Grupos ────────────────────────────────────────────────────────────────
  static Future<void> _initializeSampleGroups() async {
    final groups = [
      {
        'id': 'g1',
        'name': 'Grupo Proyecto IS',
        'description':
            'Equipo para el proyecto final de Ingeniería de Software',
        'memberCount': 4,
        'isJoined': true,
        'members': [
          {'id': 'u_student_1', 'name': 'David Barceló', 'role': 'student'},
          {'id': 'u2', 'name': 'Ana García', 'role': 'student'},
          {'id': 'u3', 'name': 'Carlos Ruiz', 'role': 'student'},
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
      },
    ];
    await LocalStorageService.setList(LocalStorageService.groupsKey, groups);
  }
}
