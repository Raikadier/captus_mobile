import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/api_client.dart';
import '../services/fcm_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const AuthState.loading()
      : status = AuthStatus.loading,
        user = null,
        errorMessage = null;

  const AuthState.authenticated(User user)
      : status = AuthStatus.authenticated,
        user = user,
        errorMessage = null;

  const AuthState.unauthenticated([String? error])
      : status = AuthStatus.unauthenticated,
        user = null,
        errorMessage = error;

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  String get role =>
      (user?.userMetadata?['role'] as String?) ?? 'student';

  String get displayName =>
      (user?.userMetadata?['display_name'] as String?) ??
      (user?.userMetadata?['name'] as String?) ??
      user?.email?.split('@').first ??
      'Usuario';

  String get email => user?.email ?? '';
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    // Listen to Supabase auth changes and update state accordingly.
    SupabaseService.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        state = AsyncData(AuthState.authenticated(session.user));
      } else {
        state = const AsyncData(AuthState.unauthenticated());
      }
    });

    // Return the initial state from the persisted session.
    final user = SupabaseService.currentUser;
    if (user != null) return AuthState.authenticated(user);
    return const AuthState.unauthenticated();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Sign in with email + password.
  /// Returns null on success, an error message on failure.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncData(AuthState.loading());
    try {
      final res = await SupabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user == null) {
        state = const AsyncData(AuthState.unauthenticated('Credenciales inválidas'));
        return 'Credenciales inválidas';
      }

      // Sync user profile to our backend (same pattern as the web app).
      _syncToBackend();

      state = AsyncData(AuthState.authenticated(res.user!));
      return null;
    } on AuthException catch (e) {
      final msg = _mapAuthError(e.message);
      state = AsyncData(AuthState.unauthenticated(msg));
      return msg;
    } catch (e) {
      const msg = 'Error de conexión. Intenta de nuevo.';
      state = const AsyncData(AuthState.unauthenticated(msg));
      return msg;
    }
  }

  /// Register a new user.
  /// Returns null on success, an error message on failure.
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    String role = 'student',
  }) async {
    state = const AsyncData(AuthState.loading());
    try {
      final res = await SupabaseService.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'display_name': name,
          'full_name': name,
          'role': role,
        },
      );

      if (res.user == null) {
        state = const AsyncData(AuthState.unauthenticated());
        return 'No se pudo crear la cuenta. Intenta de nuevo.';
      }

      // If email confirmation is enabled, the session may be null.
      if (res.session != null) {
        _syncToBackend();
        state = AsyncData(AuthState.authenticated(res.user!));
      } else {
        // Email confirmation pending.
        state = const AsyncData(AuthState.unauthenticated());
      }
      return null;
    } on AuthException catch (e) {
      final msg = _mapAuthError(e.message);
      state = AsyncData(AuthState.unauthenticated(msg));
      return msg;
    } catch (e) {
      const msg = 'Error al registrarse. Intenta de nuevo.';
      state = const AsyncData(AuthState.unauthenticated(msg));
      return msg;
    }
  }

  /// Send a password reset email.
  Future<String?> sendPasswordReset(String email) async {
    try {
      await SupabaseService.auth.resetPasswordForEmail(email);
      return null;
    } on AuthException catch (e) {
      return _mapAuthError(e.message);
    } catch (_) {
      return 'Error al enviar el correo.';
    }
  }

  /// Sign out and clear local state.
  Future<void> signOut() async {
    // Unregister FCM token so this device stops receiving push notifications.
    await FcmService.deleteToken();
    await SupabaseService.auth.signOut();
    state = const AsyncData(AuthState.unauthenticated());
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Fire-and-forget backend sync (same as web AuthContext.login does).
  void _syncToBackend() {
    ApiClient.instance
        .post('/users/sync')
        // ignore: avoid_types_on_closure_parameters
        .catchError((Object _) => Response(
              requestOptions: RequestOptions(path: '/users/sync'),
              statusCode: 0,
            ));
  }

  String _mapAuthError(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid password')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Confirma tu correo antes de ingresar.';
    }
    if (lower.contains('user already registered') ||
        lower.contains('already been registered')) {
      return 'Este correo ya está registrado.';
    }
    if (lower.contains('password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (lower.contains('rate limit') || lower.contains('too many')) {
      return 'Demasiados intentos. Espera unos minutos.';
    }
    return raw;
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// The main auth provider. Watch this from the router and any screen
/// that needs to know if the user is logged in.
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Convenience provider — just the current [User] or null.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).valueOrNull?.user;
});

/// Convenience provider — just the role string ('student' | 'teacher').
final userRoleProvider = Provider<String>((ref) {
  return ref.watch(authProvider).valueOrNull?.role ?? 'student';
});
