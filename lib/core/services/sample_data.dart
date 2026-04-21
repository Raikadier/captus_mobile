import '../services/local_storage_service.dart';

class SampleData {
  static Future<void> initializeSampleData() async {
    final existingCourses = LocalStorageService.courses;
    if (existingCourses.isNotEmpty) return;

    await _initializeSampleTasks();
    await _initializeSampleCourses();
    await _initializeSampleEvents();
    await _initializeSampleGroups();
  }

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
    ];
    await LocalStorageService.setList(LocalStorageService.tasksKey, tasks);
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
    await LocalStorageService.setList(LocalStorageService.coursesKey, courses);
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
      },
    ];
    await LocalStorageService.setList(LocalStorageService.eventsKey, events);
  }

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
      },
    ];
    await LocalStorageService.setList(LocalStorageService.groupsKey, groups);
  }
}
