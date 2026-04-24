import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:captus_mobile/core/providers/auth_provider.dart';
import 'package:captus_mobile/core/services/supabase_service.dart';
import 'package:captus_mobile/core/services/api_client.dart';

import 'auth_provider_test.mocks.dart';

@GenerateMocks([SupabaseService, ApiClient, AuthException])
void main() {
  group('AuthProvider Tests', () {
    late MockSupabaseService mockSupabaseService;
    late MockApiClient mockApiClient;

    setUp(() {
      mockSupabaseService = MockSupabaseService();
      mockApiClient = MockApiClient();
    });

    group('LocalUser Tests', () {
      test('should create LocalUser with required fields', () {
        const user = LocalUser(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          role: 'student',
        );

        expect(user.id, '123');
        expect(user.email, 'test@example.com');
        expect(user.name, 'Test User');
        expect(user.role, 'student');
      });

      test('should convert to JSON correctly', () {
        const user = LocalUser(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          role: 'student',
          university: 'Test University',
        );

        final json = user.toJson();
        expect(json['id'], '123');
        expect(json['email'], 'test@example.com');
        expect(json['name'], 'Test User');
        expect(json['role'], 'student');
        expect(json['university'], 'Test University');
      });

      test('should create from JSON correctly', () {
        final json = {
          'id': '123',
          'email': 'test@example.com',
          'name': 'Test User',
          'role': 'teacher',
          'university': 'Test University',
          'career': 'Computer Science',
          'semester': 5,
        };

        final user = LocalUser.fromJson(json);
        expect(user.id, '123');
        expect(user.email, 'test@example.com');
        expect(user.name, 'Test User');
        expect(user.role, 'teacher');
        expect(user.university, 'Test University');
        expect(user.career, 'Computer Science');
        expect(user.semester, 5);
      });

      test('should copy with new values', () {
        const original = LocalUser(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          role: 'student',
        );

        final updated = original.copyWith(
          name: 'Updated Name',
          role: 'teacher',
          university: 'New University',
        );

        expect(updated.id, original.id);
        expect(updated.email, original.email);
        expect(updated.name, 'Updated Name');
        expect(updated.role, 'teacher');
        expect(updated.university, 'New University');
      });
    });

    group('AuthState Tests', () {
      test('should create loading state', () {
        const state = AuthState.loading();
        expect(state.status, AuthStatus.loading);
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
        expect(state.isLoading, false);
        expect(state.isAuthenticated, true);
        expect(state.role, 'student');
        expect(state.displayName, 'Test User');
        expect(state.email, 'test@example.com');
      });

      test('should create unauthenticated state', () {
        const state = AuthState.unauthenticated('Error message');
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.user, null);
        expect(state.isLoading, false);
        expect(state.isAuthenticated, false);
        expect(state.errorMessage, 'Error message');
      });

      test('should handle null user in getters', () {
        const state = AuthState.unauthenticated();
        expect(state.role, 'student');
        expect(state.displayName, 'Usuario');
        expect(state.email, '');
      });
    });

    group('Error Mapping Tests', () {
      test('should map invalid credentials error', () {
        final authNotifier = AuthNotifier();
        final errorMessage = authNotifier._mapAuthError('Invalid login credentials');
        expect(errorMessage, 'Correo o contraseña incorrectos');
      });

      test('should map already registered error', () {
        final authNotifier = AuthNotifier();
        final errorMessage = authNotifier._mapAuthError('User already registered');
        expect(errorMessage, 'Este correo ya está registrado');
      });

      test('should map email not confirmed error', () {
        final authNotifier = AuthNotifier();
        final errorMessage = authNotifier._mapAuthError('Email not confirmed');
        expect(errorMessage, 'Confirma tu correo antes de iniciar sesión');
      });

      test('should map password length error', () {
        final authNotifier = AuthNotifier();
        final errorMessage = authNotifier._mapAuthError('Password should be at least 6 characters');
        expect(errorMessage, 'La contraseña debe tener al menos 6 caracteres');
      });

      test('should return original message for unknown errors', () {
        final authNotifier = AuthNotifier();
        final errorMessage = authNotifier._mapAuthError('Unknown error');
        expect(errorMessage, 'Unknown error');
      });
    });

    group('Provider Integration Tests', () {
      test('currentUserProvider should return current user', () {
        final container = ProviderContainer();
        const user = LocalUser(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          role: 'student',
        );

        final authState = AuthState.authenticated(user);
        container.listen(authProvider, (_, __) {});
        container.read(authProvider.notifier).state = AsyncData(authState);

        final currentUser = container.read(currentUserProvider);
        expect(currentUser, user);
      });

      test('userRoleProvider should return student role by default', () {
        final container = ProviderContainer();
        container.listen(authProvider, (_, __) {});
        container.read(authProvider.notifier).state = const AsyncData(AuthState.unauthenticated());

        final userRole = container.read(userRoleProvider);
        expect(userRole, 'student');
      });

      test('userRoleProvider should return user role when authenticated', () {
        final container = ProviderContainer();
        const user = LocalUser(
          id: '123',
          email: 'test@example.com',
          name: 'Test User',
          role: 'teacher',
        );

        final authState = AuthState.authenticated(user);
        container.listen(authProvider, (_, __) {});
        container.read(authProvider.notifier).state = AsyncData(authState);

        final userRole = container.read(userRoleProvider);
        expect(userRole, 'teacher');
      });
    });
  });

  group('LocalUser from Supabase Tests', () {
    test('should create from Supabase user with metadata', () {
      final metadata = {
        'name': 'John Doe',
        'role': 'student',
        'university': 'Test University',
        'career': 'Computer Science',
        'semester': 5,
        'bio': 'Test bio',
        'avatar_url': 'https://example.com/avatar.jpg',
      };

      final mockSupabaseUser = MockUser(
        id: '123',
        email: 'john@example.com',
        userMetadata: metadata,
      );

      final localUser = LocalUser.fromSupabase(mockSupabaseUser);
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

    test('should handle missing metadata', () {
      final mockSupabaseUser = MockUser(
        id: '456',
        email: 'jane@example.com',
      );

      final localUser = LocalUser.fromSupabase(mockSupabaseUser);
      expect(localUser.id, '456');
      expect(localUser.email, 'jane@example.com');
      expect(localUser.name, '');
      expect(localUser.role, 'student');
      expect(localUser.university, null);
      expect(localUser.career, null);
      expect(localUser.semester, null);
      expect(localUser.bio, null);
      expect(localUser.avatarUrl, null);
    });

    test('should handle different name fields', () {
      final metadata = {
        'full_name': 'Jane Smith',
        'display_name': 'Jane',
        'role': 'teacher',
      };

      final mockSupabaseUser = MockUser(
        id: '789',
        email: 'jane@example.com',
        userMetadata: metadata,
      );

      final localUser = LocalUser.fromSupabase(mockSupabaseUser);
      expect(localUser.name, 'Jane Smith');
      expect(localUser.role, 'teacher');
    });
  });
}

// Mock User class for testing
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
