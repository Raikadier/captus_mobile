import 'package:flutter_test/flutter_test.dart';
import 'package:captus_mobile/core/providers/auth_provider.dart';

/// Pure unit tests for the [AuthState] value class.
/// These do not require Flutter widgets, Firebase or Supabase.
void main() {
  group('AuthState.loading', () {
    late AuthState state;

    setUp(() => state = const AuthState.loading());

    test('status is loading', () {
      expect(state.status, AuthStatus.loading);
    });

    test('isLoading returns true', () {
      expect(state.isLoading, true);
    });

    test('isAuthenticated returns false', () {
      expect(state.isAuthenticated, false);
    });

    test('user is null', () {
      expect(state.user, isNull);
    });

    test('errorMessage is null', () {
      expect(state.errorMessage, isNull);
    });
  });

  group('AuthState.unauthenticated', () {
    test('creates state with no error by default', () {
      const state = AuthState.unauthenticated();
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.isLoading, false);
      expect(state.isAuthenticated, false);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
    });

    test('stores error message when provided', () {
      const state = AuthState.unauthenticated('Credenciales inválidas');
      expect(state.errorMessage, 'Credenciales inválidas');
    });

    test('role defaults to "student" when user is null', () {
      const state = AuthState.unauthenticated();
      expect(state.role, 'student');
    });

    test('displayName falls back to "Usuario" when user is null', () {
      const state = AuthState.unauthenticated();
      expect(state.displayName, 'Usuario');
    });

    test('email is empty string when user is null', () {
      const state = AuthState.unauthenticated();
      expect(state.email, '');
    });
  });

  group('AuthStatus enum', () {
    test('has exactly three values', () {
      expect(AuthStatus.values, hasLength(3));
    });

    test('contains loading, authenticated, unauthenticated', () {
      expect(
          AuthStatus.values,
          containsAll([
            AuthStatus.loading,
            AuthStatus.authenticated,
            AuthStatus.unauthenticated,
          ]));
    });
  });
}
