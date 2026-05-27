// ignore_for_file: subtype_of_sealed_class

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:captus_mobile/core/providers/auth_provider.dart';
import 'package:captus_mobile/core/services/local_storage_service.dart';

void main() {
  setUp(() async {
    dotenv.testLoad(mergeWith: {
      'API_BASE_URL': 'http://localhost:3000/api',
      'SUPABASE_URL': '',
      'SUPABASE_ANON_KEY': '',
    });
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.initialize();
  });
  group('LocalUser Tests', () {
    test('should create LocalUser with required fields', () {
      const user = LocalUser(
        id: '123',
        email: 'test@test.com',
        name: 'Test',
        role: 'student',
      );

      expect(user.id, '123');
      expect(user.email, 'test@test.com');
      expect(user.name, 'Test');
      expect(user.role, 'student');
      expect(user.university, null);
      expect(user.career, null);
      expect(user.semester, null);
      expect(user.bio, null);
      expect(user.avatarUrl, null);
    });

    test('should convert to JSON correctly', () {
      const user = LocalUser(
        id: '123',
        email: 'test@test.com',
        name: 'Test User',
        role: 'teacher',
        university: 'Test University',
        career: 'CS',
        semester: 5,
        bio: 'Bio',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['email'], 'test@test.com');
      expect(json['name'], 'Test User');
      expect(json['role'], 'teacher');
      expect(json['university'], 'Test University');
      expect(json['career'], 'CS');
      expect(json['semester'], 5);
      expect(json['bio'], 'Bio');
      expect(json['avatarUrl'], 'https://example.com/avatar.jpg');
    });

    test('should create from JSON', () {
      final json = {
        'id': '123',
        'email': 'test@test.com',
        'name': 'Test',
        'role': 'student',
        'university': 'University',
        'semester': 3,
      };

      final user = LocalUser.fromJson(json);

      expect(user.id, '123');
      expect(user.email, 'test@test.com');
      expect(user.name, 'Test');
      expect(user.role, 'student');
      expect(user.university, 'University');
      expect(user.semester, 3);
    });

    test('should handle missing fields in JSON', () {
      final json = {'id': '123'};
      final user = LocalUser.fromJson(json);

      expect(user.id, '123');
      expect(user.email, '');
      expect(user.name, '');
      expect(user.role, 'student');
    });

    test('copyWith should update only specified fields', () {
      const user = LocalUser(
        id: '123',
        email: 'test@test.com',
        name: 'Original',
        role: 'student',
      );

      final updated = user.copyWith(name: 'Updated', role: 'teacher');

      expect(updated.id, '123');
      expect(updated.email, 'test@test.com');
      expect(updated.name, 'Updated');
      expect(updated.role, 'teacher');
    });

    test('copyWith should preserve fields when null', () {
      const user = LocalUser(
        id: '123',
        email: 'test@test.com',
        name: 'Original',
        role: 'student',
        university: 'University',
      );

      final updated = user.copyWith(name: 'Updated');

      expect(updated.id, '123');
      expect(updated.email, 'test@test.com');
      expect(updated.name, 'Updated');
      expect(updated.role, 'student');
      expect(updated.university, 'University');
    });
  });

  group('AuthState Tests', () {
    test('loading state', () {
      final state = AuthState.loading();

      expect(state.status, AuthStatus.loading);
      expect(state.user, null);
      expect(state.errorMessage, null);
      expect(state.isLoading, true);
      expect(state.isAuthenticated, false);
    });

    test('authenticated state', () {
      const user = LocalUser(
        id: '123',
        email: 'test@test.com',
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
      expect(state.email, 'test@test.com');
    });

    test('unauthenticated state', () {
      final state = AuthState.unauthenticated();

      expect(state.status, AuthStatus.unauthenticated);
      expect(state.user, null);
      expect(state.errorMessage, null);
      expect(state.isLoading, false);
      expect(state.isAuthenticated, false);
    });

    test('unauthenticated state with error', () {
      final state = AuthState.unauthenticated('Error message');

      expect(state.errorMessage, 'Error message');
    });

    test('getters return defaults when user is null', () {
      final state = AuthState.unauthenticated();

      expect(state.role, 'student');
      expect(state.displayName, 'Usuario');
      expect(state.email, '');
    });
  });

  group('AuthNotifier initial state', () {
    test('should start with unauthenticated state when no session', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final state = await container.read(authProvider.future);

      expect(state.status, AuthStatus.unauthenticated);
      expect(state.isAuthenticated, false);
    });
  });

  group('AuthNotifier sendPasswordReset and resendConfirmation', () {
    test('sendPasswordReset should return null', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final result =
          await container.read(authProvider.notifier).sendPasswordReset('test@test.com');

      expect(result, null);
    });

    test('resendConfirmation should return null', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      final result =
          await container.read(authProvider.notifier).resendConfirmation('test@test.com');

      expect(result, null);
    });
  });

  group('AuthNotifier signOut', () {
    test('signOut should set unauthenticated state', () async {
      final container = ProviderContainer();
      addTearDown(() => container.dispose());

      await container.read(authProvider.notifier).signOut();

      final state = container.read(authProvider).value;
      expect(state!.status, AuthStatus.unauthenticated);
    });
  });

  group('AuthStatus enum', () {
    test('should have correct values', () {
      expect(AuthStatus.values, hasLength(3));
      expect(AuthStatus.values, containsAll([AuthStatus.loading, AuthStatus.authenticated, AuthStatus.unauthenticated]));
    });
  });
}
