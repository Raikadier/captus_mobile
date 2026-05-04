import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:captus_mobile/core/providers/auth_provider.dart';

void main() {
  group('LocalUser Tests', () {
    test('should create LocalUser with required fields', () {
      const localUser = LocalUser(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        role: 'student',
      );

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

      final json = localUser.toJson();

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
      const localUser = LocalUser(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        role: 'student',
      );

      final json = localUser.toJson();

      expect(json['avatarUrl'], '');
    });

    test('should create LocalUser from JSON', () {
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

      final localUser = LocalUser.fromJson(json);

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
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'name': 'Test User',
      };

      final localUser = LocalUser.fromJson(json);

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

    test('should handle null values in JSON', () {
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

      final localUser = LocalUser.fromJson(json);

      expect(localUser.id, '');
      expect(localUser.email, '');
      expect(localUser.name, '');
      expect(localUser.role, 'student');
      expect(localUser.university, null);
      expect(localUser.career, null);
      expect(localUser.semester, null);
      expect(localUser.bio, null);
      expect(localUser.avatarUrl, null);
    });

    test('should copy with new values', () {
      const originalUser = LocalUser(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        role: 'student',
        university: 'Test University',
        career: 'Computer Science',
        semester: 5,
      );

      final updatedUser = originalUser.copyWith(
        name: 'Updated Name',
        role: 'teacher',
        semester: 6,
        bio: 'Updated bio',
      );

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

      final localUser = LocalUser.fromSupabase(mockUser);

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
      final metadata = {
        'full_name': 'Jane Doe',
        'role': 'teacher',
      };

      final mockUser = MockUser(
        id: '456',
        email: 'jane@example.com',
        userMetadata: metadata,
      );

      final localUser = LocalUser.fromSupabase(mockUser);

      expect(localUser.name, 'Jane Doe');
      expect(localUser.role, 'teacher');
    });

    test('should handle missing metadata in Supabase User', () {
      final mockUser = MockUser(
        id: '789',
        email: 'test@example.com',
      );

      final localUser = LocalUser.fromSupabase(mockUser);

      expect(localUser.id, '789');
      expect(localUser.email, 'test@example.com');
      expect(localUser.name, '');
      expect(localUser.role, 'student');
      expect(localUser.university, null);
      expect(localUser.career, null);
      expect(localUser.semester, null);
      expect(localUser.bio, null);
      expect(localUser.avatarUrl, null);
    });
  });

  group('AuthState Tests', () {
    test('should create loading state', () {
      final state = AuthState.loading();

      expect(state.status, AuthStatus.loading);
      expect(state.user, null);
      expect(state.errorMessage, null);
      expect(state.isLoading, true);
      expect(state.isAuthenticated, false);
    });

    test('should create authenticated state', () {
      const user = LocalUser(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        role: 'student',
      );

      final state = AuthState.authenticated(user);

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
      final state = AuthState.unauthenticated();

      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, null);
      expect(state.errorMessage, null);
      expect(state.isLoading, false);
      expect(state.isAuthenticated, false);
      expect(state.role, 'student');
      expect(state.displayName, 'Usuario');
      expect(state.email, '');
    });

    test('should create unauthenticated state with error', () {
      final state = AuthState.unauthenticated('Login failed');

      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, null);
      expect(state.errorMessage, 'Login failed');
      expect(state.isLoading, false);
      expect(state.isAuthenticated, false);
    });

    test('should handle null user in getters', () {
      final state = AuthState.unauthenticated();

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

class MockUser extends User {
  MockUser({
    required super.id,
    super.email,
    super.userMetadata,
  }) : super(
          appMetadata: const {},
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
        );
}