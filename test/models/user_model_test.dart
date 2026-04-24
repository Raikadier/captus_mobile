import 'package:flutter_test/flutter_test.dart';
import 'package:captus_mobile/models/user.dart';

void main() {
  group('UserModel Tests', () {
    test('should create UserModel from valid JSON', () {
      // Arrange
      final json = {
        'id': '123',
        'name': 'John Doe',
        'email': 'john@example.com',
        'university': 'Test University',
        'career': 'Computer Science',
        'semester': 5,
        'role': 'student',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'bio': 'Test bio',
        'createdAt': '2024-01-15T10:00:00.000Z',
        'updatedAt': '2024-01-15T10:00:00.000Z',
      };

      // Act
      final userModel = UserModel.fromJson(json);

      // Assert
      expect(userModel.id, '123');
      expect(userModel.name, 'John Doe');
      expect(userModel.email, 'john@example.com');
      expect(userModel.university, 'Test University');
      expect(userModel.career, 'Computer Science');
      expect(userModel.semester, 5);
      expect(userModel.role, UserRole.student);
      expect(userModel.avatarUrl, 'https://example.com/avatar.jpg');
      expect(userModel.bio, 'Test bio');
      expect(userModel.createdAt, DateTime.parse('2024-01-15T10:00:00.000Z'));
      expect(userModel.updatedAt, DateTime.parse('2024-01-15T10:00:00.000Z'));
    });

    test('should handle null values in JSON', () {
      // Arrange
      final json = {
        'id': '123',
        'name': 'John Doe',
        'email': 'john@example.com',
        'role': 'student',
      };

      // Act
      final userModel = UserModel.fromJson(json);

      // Assert
      expect(userModel.id, '123');
      expect(userModel.name, 'John Doe');
      expect(userModel.email, 'john@example.com');
      expect(userModel.university, null);
      expect(userModel.career, null);
      expect(userModel.semester, null);
      expect(userModel.role, UserRole.student);
      expect(userModel.avatarUrl, null);
      expect(userModel.bio, null);
      expect(userModel.createdAt, null);
      expect(userModel.updatedAt, null);
    });

    test('should convert to JSON correctly', () {
      // Arrange
      final userModel = UserModel(
        id: '123',
        name: 'John Doe',
        email: 'john@example.com',
        university: 'Test University',
        career: 'Computer Science',
        semester: 5,
        role: UserRole.student,
        avatarUrl: 'https://example.com/avatar.jpg',
        bio: 'Test bio',
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      // Act
      final json = userModel.toJson();

      // Assert
      expect(json['id'], '123');
      expect(json['name'], 'John Doe');
      expect(json['email'], 'john@example.com');
      expect(json['university'], 'Test University');
      expect(json['career'], 'Computer Science');
      expect(json['semester'], 5);
      expect(json['role'], 'student');
      expect(json['avatarUrl'], 'https://example.com/avatar.jpg');
      expect(json['bio'], 'Test bio');
      expect(json['createdAt'], '2024-01-15T00:00:00.000Z');
      expect(json['updatedAt'], '2024-01-15T00:00:00.000Z');
    });

    test('should copy with new values', () {
      // Arrange
      final originalUser = UserModel.mock;

      // Act
      final updatedUser = originalUser.copyWith(
        name: 'Updated Name',
        semester: 6,
        bio: 'Updated bio',
      );

      // Assert
      expect(updatedUser.id, originalUser.id);
      expect(updatedUser.email, originalUser.email);
      expect(updatedUser.name, 'Updated Name');
      expect(updatedUser.semester, 6);
      expect(updatedUser.bio, 'Updated bio');
      expect(updatedUser.university, originalUser.university);
      expect(updatedUser.career, originalUser.career);
      expect(updatedUser.role, originalUser.role);
    });

    test('should return correct first name', () {
      // Arrange
      final userModel = UserModel(
        id: '123',
        name: 'John Doe Smith',
        email: 'john@example.com',
        role: UserRole.student,
      );

      // Act & Assert
      expect(userModel.firstName, 'John');
    });

    test('should handle single name correctly', () {
      // Arrange
      final userModel = UserModel(
        id: '123',
        name: 'John',
        email: 'john@example.com',
        role: UserRole.student,
      );

      // Act & Assert
      expect(userModel.firstName, 'John');
    });

    test('should handle empty name correctly', () {
      // Arrange
      final userModel = UserModel(
        id: '123',
        name: '',
        email: 'john@example.com',
        role: UserRole.student,
      );

      // Act & Assert
      expect(userModel.firstName, '');
    });

    test('should convert teacher role correctly', () {
      // Arrange
      final json = {
        'id': '123',
        'name': 'Teacher Name',
        'email': 'teacher@example.com',
        'role': 'teacher',
      };

      // Act
      final userModel = UserModel.fromJson(json);

      // Assert
      expect(userModel.role, UserRole.teacher);
    });

    test('should convert from LocalUser correctly', () {
      // Arrange
      final localUser = {
        'id': '123',
        'name': 'John Doe',
        'email': 'john@example.com',
        'role': 'student',
        'university': 'Test University',
        'career': 'Computer Science',
        'semester': 5,
        'avatarUrl': 'https://example.com/avatar.jpg',
        'bio': 'Test bio',
      };

      // Act
      final userModel = UserModel.fromLocalUser(localUser);

      // Assert
      expect(userModel.id, '123');
      expect(userModel.name, 'John Doe');
      expect(userModel.email, 'john@example.com');
      expect(userModel.role, UserRole.student);
      expect(userModel.university, 'Test University');
      expect(userModel.career, 'Computer Science');
      expect(userModel.semester, 5);
      expect(userModel.avatarUrl, 'https://example.com/avatar.jpg');
      expect(userModel.bio, 'Test bio');
      expect(userModel.createdAt, isNotNull);
    });

    test('should handle null LocalUser correctly', () {
      // Act
      final userModel = UserModel.fromLocalUser(null);

      // Assert
      expect(userModel, UserModel.mock);
    });
  });

  group('UserRole Tests', () {
    test('should have correct enum values', () {
      expect(UserRole.student, isA<UserRole>());
      expect(UserRole.teacher, isA<UserRole>());
    });
  });

  group('UserModel Mock Tests', () {
    test('should provide valid mock student', () {
      // Act
      final mockStudent = UserModel.mock;

      // Assert
      expect(mockStudent.id, '1');
      expect(mockStudent.name, 'David Barceló');
      expect(mockStudent.email, 'dbarcelo@unicesar.edu.co');
      expect(mockStudent.role, UserRole.student);
      expect(mockStudent.university, 'Universidad Popular del Cesar');
      expect(mockStudent.career, 'Ingeniería de Sistemas');
      expect(mockStudent.semester, 5);
    });

    test('should provide valid mock teacher', () {
      // Act
      final mockTeacher = UserModel.mockTeacher;

      // Assert
      expect(mockTeacher.id, '2');
      expect(mockTeacher.name, 'Profesor Martínez');
      expect(mockTeacher.email, 'pmartinez@unicesar.edu.co');
      expect(mockTeacher.role, UserRole.teacher);
      expect(mockTeacher.university, 'Universidad Popular del Cesar');
      expect(mockTeacher.career, 'Docente');
      expect(mockTeacher.semester, 0);
    });
  });
}
