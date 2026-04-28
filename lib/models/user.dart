enum UserRole { student, teacher }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? university;
  final String? career;
  final int? semester;
  final UserRole role;
  final String? avatarUrl;
  final String? bio;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.university,
    this.career,
    this.semester,
    required this.role,
    this.avatarUrl,
    this.bio,
    this.createdAt,
    this.updatedAt,
  });

  String get firstName {
    final parts = name.split(' ');
    if (parts.isEmpty) return '';
    return parts[0][0].toUpperCase() + parts[0].substring(1).toLowerCase();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      university: json['university']?.toString(),
      career: json['career']?.toString(),
      semester: json['semester'] as int?,
      role: json['role']?.toString() == 'teacher'
          ? UserRole.teacher
          : UserRole.student,
      avatarUrl: json['avatarUrl']?.toString(),
      bio: json['bio']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  factory UserModel.fromLocalUser(dynamic authUser) {
    return UserModel(
      id: authUser.id ?? '',
      name: authUser.name ?? '',
      email: authUser.email ?? '',
      role: UserRole.student, // o lógica si tienes roles
      career: '',
      bio: '',
      university: '',
      semester: 0,
      avatarUrl: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'university': university,
      'career': career,
      'semester': semester,
      'role': role == UserRole.teacher ? 'teacher' : 'student',
      'avatarUrl': avatarUrl ?? '',
      'bio': bio,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? university,
    String? career,
    int? semester,
    UserRole? role,
    String? avatarUrl,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      university: university ?? this.university,
      career: career ?? this.career,
      semester: semester ?? this.semester,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static UserModel get mock => UserModel(
        id: '1',
        name: 'David Barceló',
        email: 'dbarcelo@unicesar.edu.co',
        university: 'Universidad Popular del Cesar',
        career: 'Ingeniería de Sistemas',
        semester: 5,
        role: UserRole.student,
        avatarUrl: '',
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
        avatarUrl: '',
        createdAt: DateTime(2023, 8, 1),
      );
}
