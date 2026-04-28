import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:captus_mobile/core/providers/auth_provider.dart';

void main() {
  group('LocalUser Tests', () {
    test('should create LocalUser with required fields', () {
      // Arrange & Act
      const localUser = LocalUser(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        role: 'student',
      );

      // Assert
      expect(localUser.id, '123');
      expect(localUser.email, 'test@example.com');
      expect(localUser.name, 'Test User');
      expect(localUser.role, 'student');
      expect(localUser.university, null);
      expect(localUser.career, null);
      expect(localUser.semester, null);
      expect(localUser.bio, null);
      expect(localUser.avatarUrl, null);
    });

    test('should create LocalUser with all fields', () {
      // Arrange & Act
      const localUser = LocalUser(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        role: 'teacher',
        university: 'Test University',
        career: 'Computer Science',
        semester: 5,
        bio: 'Test bio',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      // Assert
      expect(localUser.id, '123');
      expect(localUser.email, 'test@example.com');
      expect(localUser.name, 'Test User');
      expect(localUser.role, 'teacher');
      expect(localUser.university, 'Test University');
      expect(localUser.career, 'Computer Science');
      expect(localUser.semester, 5);
      expect(localUser.bio, 'Test bio');
      expect(localUser.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('should convert to JSON correctly', () {
      // Arrange
      const localUser = LocalUser(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        role: 'student',
        university: 'Test University',
        career: 'Computer Science',
        semester: 5,
        bio: 'Test bio',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      // Act
      final json = localUser.toJson();

      // Assert
      expect(json['id'], '123');
      expect(json['email'], 'test@example.com');
      expect(json['name'], 'Test User');
      expect(json['role'], 'student');
      expect(json['university'], 'Test University');
      expect(json['career'], 'Computer Science');
      expect(json['semester'], 5);
      expect(json['bio'], 'Test bio');
      expect(json['avatarUrl'], 'https://example.com/avatar.jpg');
    });

    test('should handle null avatarUrl in JSON conversion', () {
      // Arrange
      const localUser = LocalUser(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        role: 'student',
      );

      // Act
      final json = localUser.toJson();

      // Assert
      expect(json['avatarUrl'], '');
    });

    test('should create LocalUser from JSON', () {
      // Arrange
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'name': 'Test User',
        'role': 'teacher',
        'university': 'Test University',
        'career': 'Computer Science',
        'semester': 5,
        'bio': 'Test bio',
        'avatarUrl': 'https://example.com/avatar.jpg',
      };

      // Act
      final localUser = LocalUser.fromJson(json);

      // Assert
      expect(localUser.id, '123');
      expect(localUser.email, 'test@example.com');
      expect(localUser.name, 'Test User');
      expect(localUser.role, 'teacher');
      expect(localUser.university, 'Test University');
      expect(localUser.career, 'Computer Science');
      expect(localUser.semester, 5);
      expect(localUser.bio, 'Test bio');
      expect(localUser.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('should handle missing fields in JSON', () {
      // Arrange
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'name': 'Test User',
      };

      // Act
      final localUser = LocalUser.fromJson(json);

      // Assert
      expect(localUser.id, '123');
      expect(localUser.email, 'test@example.com');
      expect(localUser.name, 'Test User');
      expect(localUser.role, 'student'); // default value
      expect(localUser.university, null);
      expect(localUser.career, null);
      expect(localUser.semester, null);
      expect(localUser.bio, null);
      expect(localUser.avatarUrl, null);
    });

    test('should handle null values in JSON', () {
      // Arrange
      final json = {
        'id': null,
        'email': null,
        'name': null,
        'role': null,
        'university': null,
        'career': null,
        'semester': null,
        'bio': null,
        'avatarUrl': null,
      };

      // Act
      final localUser = LocalUser.fromJson(json);

      // Assert
      expect(localUser.id, '');
      expect(localUser.email, '');
      expect(localUser.name, '');
      expect(localUser.role, 'student'); // default value
      expect(localUser.university, null);
      expect(localUser.career, null);
      expect(localUser.semester, null);
      expect(localUser.bio, null);
      expect(localUser.avatarUrl, null);
    });

    test('should copy with new values', () {
      // Arrange
      const originalUser = LocalUser(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        role: 'student',
        university: 'Test University',
        career: 'Computer Science',
        semester: 5,
      );

      // Act
      final updatedUser = originalUser.copyWith(
        name: 'Updated Name',
        role: 'teacher',
        semester: 6,
        bio: 'Updated bio',
      );

      // Assert
      expect(updatedUser.id, originalUser.id);
      expect(updatedUser.email, originalUser.email);
      expect(updatedUser.name, 'Updated Name');
      expect(updatedUser.role, 'teacher');
      expect(updatedUser.university, originalUser.university);
      expect(updatedUser.career, originalUser.career);
      expect(updatedUser.semester, 6);
      expect(updatedUser.bio, 'Updated bio');
      expect(updatedUser.avatarUrl, originalUser.avatarUrl);
    });

    test('should create from Supabase User with metadata', () {
      // Arrange
      final metadata = {
        'name': 'John Doe',
        'role': 'student',
        'university': 'Test University',
        'career': 'Computer Science',
        'semester': 5,
        'bio': 'Test bio',
        'avatar_url': 'https://example.com/avatar.jpg',
      };

      final mockUser = MockUser(
        id: '123',
        email: 'john@example.com',
        userMetadata: metadata,
      );

      // Act
      final localUser = LocalUser.fromSupabase(mockUser);

      // Assert
      expect(localUser.id, '123');
      expect(localUser.email, 'john@example.com');
      expect(localUser.name, 'John Doe');
      expect(localUser.role, 'student');
      expect(localUser.university, 'Test University');
      expect(localUser.career, 'Computer Science');
      expect(localUser.semester, 5);
      expect(localUser.bio, 'Test bio');
      expect(localUser.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('should handle different name fields in Supabase metadata', () {
      // Arrange
      final metadata = {
        'full_name': 'Jane Doe',
        'role': 'teacher',
      };

      final mockUser = MockUser(
        id: '456',
        email: 'jane@example.com',
        userMetadata: metadata,
      );

      // Act
      final localUser = LocalUser.fromSupabase(mockUser);

      // Assert
      expect(localUser.name, 'Jane Doe');
      expect(localUser.role, 'teacher');
    });

    test('should handle missing metadata in Supabase User', () {
      // Arrange
      final mockUser = MockUser(
        id: '789',
        email: 'test@example.com',
      );

      // Act
      final localUser = LocalUser.fromSupabase(mockUser);

      // Assert
      expect(localUser.id, '789');
      expect(localUser.email, 'test@example.com');
      expect(localUser.name, '');
      expect(localUser.role, 'student'); // default value
      expect(localUser.university, null);
      expect(localUser.career, null);
      expect(localUser.semester, null);
      expect(localUser.bio, null);
      expect(localUser.avatarUrl, null);
    });
  });

  group('AuthState Tests', () {
    test('should create loading state', () {
      // Act
      const state = AuthState.loading();

      // Assert
      expect(state.status, AuthStatus.loading);
      expect(state.user, null);
      expect(state.errorMessage, null);
      expect(state.isLoading, true);
      expect(state.isAuthenticated, false);
    });

    test('should create authenticated state', () {
      // Arrange
      const user = LocalUser(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        role: 'student',
      );

      // Act
      final state = AuthState.authenticated(user);

      // Assert
      expect(state.status, AuthStatus.authenticated);
      expect(state.user, user);
      expect(state.errorMessage, null);
      expect(state.isLoading, false);
      expect(state.isAuthenticated, true);
      expect(state.role, 'student');
      expect(state.displayName, 'Test User');
      expect(state.email, 'test@example.com');
    });

    test('should create unauthenticated state without error', () {
      // Act
      const state = AuthState.unauthenticated();

      // Assert
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, null);
      expect(state.errorMessage, null);
      expect(state.isLoading, false);
      expect(state.isAuthenticated, false);
      expect(state.role, 'student'); // default
      expect(state.displayName, 'Usuario'); // default
      expect(state.email, ''); // default
    });

    test('should create unauthenticated state with error', () {
      // Act
      const state = AuthState.unauthenticated('Login failed');

      // Assert
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, null);
      expect(state.errorMessage, 'Login failed');
      expect(state.isLoading, false);
      expect(state.isAuthenticated, false);
    });

    test('should handle null user in getters', () {
      // Act
      const state = AuthState.unauthenticated();

      // Assert
      expect(state.role, 'student');
      expect(state.displayName, 'Usuario');
      expect(state.email, '');
    });
  });

  group('AuthStatus Tests', () {
    test('should have correct enum values', () {
      expect(AuthStatus.loading, isA<AuthStatus>());
      expect(AuthStatus.authenticated, isA<AuthStatus>());
      expect(AuthStatus.unauthenticated, isA<AuthStatus>());
    });
  });
}

// Mock classes for testing
class MockUser extends User {
  final String _id;
  final String? _email;
  final Map<String, dynamic>? _userMetadata;

  MockUser({
    required String id,
    String? email,
    Map<String, dynamic>? userMetadata,
  })  : _id = id,
        _email = email,
        _userMetadata = userMetadata;

  @override
  String get id => _id;

  @override
  String? get email => _email;

  @override
  Map<String, dynamic>? get userMetadata => _userMetadata;
}
