import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/api_client.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class LocalUser {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? university;
  final String? career;
  final int? semester;
  final String? bio;
  final String? avatarUrl;

  const LocalUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.university,
    this.career,
    this.semester,
    this.bio,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
        'university': university,
        'career': career,
        'semester': semester,
        'bio': bio,
        'avatarUrl': avatarUrl ?? '',
      };

  factory LocalUser.fromJson(Map<String, dynamic> json) => LocalUser(
        id: json['id']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        role: json['role']?.toString() ?? 'student',
        university: json['university']?.toString(),
        career: json['career']?.toString(),
        semester: json['semester'] as int?,
        bio: json['bio']?.toString(),
        avatarUrl: json['avatarUrl']?.toString(),
      );

  factory LocalUser.fromSupabase(User user) {
    final meta = user.userMetadata ?? {};
    return LocalUser(
      id: user.id,
      email: user.email ?? '',
      name: (meta['name'] ?? meta['full_name'] ?? meta['display_name'] ?? '').toString(),
      role: (meta['role'] ?? 'student').toString(),
      university: meta['university']?.toString(),
      career: meta['career']?.toString(),
      semester: meta['semester'] as int?,
      bio: meta['bio']?.toString(),
      avatarUrl: (meta['avatar_url'] ?? meta['avatarUrl'])?.toString(),
    );
  }

  LocalUser copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? university,
    String? career,
    int? semester,
    String? bio,
    String? avatarUrl,
  }) {
    return LocalUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      university: university ?? this.university,
      career: career ?? this.career,
      semester: semester ?? this.semester,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class AuthState {
  final AuthStatus status;
  final LocalUser? user;
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

  const AuthState.authenticated(this.user)
      : status = AuthStatus.authenticated,
        errorMessage = null;

  const AuthState.unauthenticated([String? error])
      : status = AuthStatus.unauthenticated,
        user = null,
        errorMessage = error;

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  String get role => user?.role ?? 'student';

  String get displayName => user?.name ?? 'Usuario';

  String get email => user?.email ?? '';
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    // Listen for Supabase auth state changes and update provider state
    SupabaseService.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        state = AsyncData(AuthState.authenticated(LocalUser.fromSupabase(session.user)));
      } else {
        state = const AsyncData(AuthState.unauthenticated());
      }
    });

    // Return current session on startup
    final session = SupabaseService.currentSession;
    if (session != null) {
      return AuthState.authenticated(LocalUser.fromSupabase(session.user));
    }
    return const AuthState.unauthenticated();
  }

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
      if (res.session == null) {
        state = const AsyncData(AuthState.unauthenticated('No se pudo iniciar sesión'));
        return 'No se pudo iniciar sesión';
      }
      final localUser = LocalUser.fromSupabase(res.user!);
      state = AsyncData(AuthState.authenticated(localUser));
      _syncUser();
      return null;
    } on AuthException catch (e) {
      final msg = _mapAuthError(e.message);
      state = AsyncData(AuthState.unauthenticated(msg));
      return msg;
    } catch (e) {
      state = const AsyncData(AuthState.unauthenticated('Error de conexión'));
      return 'Error de conexión';
    }
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    state = const AsyncData(AuthState.loading());
    try {
      final res = await SupabaseService.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'full_name': name,
          'display_name': name,
          'role': role,
        },
      );
      if (res.user == null) {
        state = const AsyncData(AuthState.unauthenticated('No se pudo crear la cuenta'));
        return 'No se pudo crear la cuenta';
      }
      if (res.session != null) {
        final localUser = LocalUser.fromSupabase(res.user!);
        state = AsyncData(AuthState.authenticated(localUser));
        _syncUser();
        return null;
      }
      // Email confirmation required
      state = const AsyncData(AuthState.unauthenticated());
      return null;
    } on AuthException catch (e) {
      final msg = _mapAuthError(e.message);
      state = AsyncData(AuthState.unauthenticated(msg));
      return msg;
    } catch (e) {
      state = const AsyncData(AuthState.unauthenticated('Error de conexión'));
      return 'Error de conexión';
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await SupabaseService.auth.resetPasswordForEmail(email);
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    await SupabaseService.auth.signOut();
    state = const AsyncData(AuthState.unauthenticated());
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (state.value?.user == null) return;
    final currentUser = state.value!.user!;
    final updatedUser = currentUser.copyWith(
      name: data['name'] ?? currentUser.name,
      university: data['university'] ?? currentUser.university,
      career: data['career'] ?? currentUser.career,
      semester: data['semester'] ?? currentUser.semester,
      bio: data['bio'] ?? currentUser.bio,
      avatarUrl: data['avatarUrl'] ?? currentUser.avatarUrl,
    );
    state = AsyncData(AuthState.authenticated(updatedUser));
  }

  void _syncUser() {
    ApiClient.instance.post<void>('/users/sync').catchError((e) => throw e);
  }

  String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials') ||
        message.contains('invalid_credentials')) {
      return 'Correo o contraseña incorrectos';
    }
    if (message.contains('already registered') || message.contains('already been registered')) {
      return 'Este correo ya está registrado';
    }
    if (message.contains('Email not confirmed')) {
      return 'Confirma tu correo antes de iniciar sesión';
    }
    if (message.contains('Password should be')) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return message;
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final currentUserProvider = Provider<LocalUser?>((ref) {
  return ref.watch(authProvider).asData?.value.user;
});

final userRoleProvider = Provider<String>((ref) {
  return ref.watch(authProvider).asData?.value.role ?? 'student';
});
