enum UserRole { student, teacher }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String university;
  final String career;
  final int semester;
  final UserRole role;
  final String? avatarUrl;
  final int streakDays;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.university,
    required this.career,
    required this.semester,
    required this.role,
    this.avatarUrl,
    this.streakDays = 0,
    required this.createdAt,
  });

  String get firstName => name.split(' ').first;

  static UserModel get mock => UserModel(
        id: '1',
        name: 'David Barceló',
        email: 'dbarcelo@unicesar.edu.co',
        university: 'Universidad Popular del Cesar',
        career: 'Ingeniería de Sistemas',
        semester: 5,
        role: UserRole.student,
        streakDays: 7,
        createdAt: DateTime(2024, 1, 15),
      );

  static UserModel get mockTeacher => UserModel(
        id: '2',
        name: 'Profesor Martínez',
        email: 'pmartinez@unicesar.edu.co',
        university: 'Universidad Popular del Cesar',
        career: 'Docente',
        semester: 0,
        role: UserRole.teacher,
        streakDays: 0,
        createdAt: DateTime(2023, 8, 1),
      );
}
