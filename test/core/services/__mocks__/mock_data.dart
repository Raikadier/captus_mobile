import 'package:captus_mobile/models/course.dart';
import 'package:captus_mobile/models/note.dart';
import 'package:captus_mobile/models/task.dart';
import 'package:captus_mobile/models/user.dart';

Map<String, dynamic> mockUserJson = {
  'id': 'user-1',
  'name': 'David Barceló',
  'email': 'dbarcelo@unicesar.edu.co',
  'university': 'Universidad Popular del Cesar',
  'career': 'Ingeniería de Sistemas',
  'semester': 5,
  'role': 'student',
  'avatarUrl': '',
  'bio': 'Test bio',
  'createdAt': '2024-01-15T00:00:00.000',
  'updatedAt': '2024-06-01T00:00:00.000',
};

UserModel mockUser = UserModel.fromJson(mockUserJson);

Map<String, dynamic> mockTaskJson = {
  'id': 1,
  'title': 'Taller Árboles Binarios',
  'description': 'Implementar algoritmos de inserción y búsqueda.',
  'priority_id': 1,
  'completed': false,
  'due_date': '2026-06-01T23:00:00.000',
  'courseId': 'c1',
  'courseName': 'Estructuras de Datos',
  'subjectName': 'Estructuras de Datos',
  'subtasks': [],
  'created_at': '2026-05-15T10:00:00.000',
  'category_id': 1,
};

TaskModel mockTask = TaskModel.fromJson(mockTaskJson);

Map<String, dynamic> mockCompletedTaskJson = {
  'id': 2,
  'title': 'Ensayo Historia',
  'description': 'Ensayo de 5 páginas.',
  'priority_id': 3,
  'completed': true,
  'due_date': '2026-05-10T23:00:00.000',
  'subtasks': [],
  'created_at': '2026-05-01T10:00:00.000',
};

TaskModel mockCompletedTask = TaskModel.fromJson(mockCompletedTaskJson);

Map<String, dynamic> mockCourseJson = {
  'id': 'c1',
  'name': 'Estructuras de Datos',
  'code': 'IS-301',
  'teacherName': 'Prof. García',
  'colorIndex': 0,
  'progress': 0.65,
  'pendingActivities': 2,
  'description': 'Algoritmos y estructuras de datos.',
  'schedule': 'Lun/Mié 10:00-12:00',
  'activities': [],
};

CourseModel mockCourse = CourseModel.fromJson(mockCourseJson);

Map<String, dynamic> mockNoteJson = {
  'id': 1,
  'created_at': '2026-05-15T10:00:00.000',
  'user_id': 'user-1',
  'title': 'Apuntes de Clase',
  'content': 'Contenido de la nota de prueba.',
  'subject': 'Estructuras de Datos',
  'is_pinned': true,
};

NoteModel mockNote = NoteModel.fromJson(mockNoteJson);

Map<String, dynamic> mockApiResponse = {
  'data': [],
  'message': 'success',
};
