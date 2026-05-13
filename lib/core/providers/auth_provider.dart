import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/local_storage_service.dart';
import '../services/sample_data.dart';
import '../../models/statistics.dart';
import '../env/env.dart';

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
    final metadata = user.userMetadata ?? {};
    return LocalUser(
      id: user.id,
      email: user.email ?? '',
      name: metadata['name']?.toString() ??
          metadata['full_name']?.toString() ??
          '',
      role: metadata['role']?.toString() ?? 'student',
      university: metadata['university']?.toString(),
      career: metadata['career']?.toString(),
      semester: metadata['semester'] as int?,
      bio: metadata['bio']?.toString(),
      avatarUrl: metadata['avatar_url']?.toString() ??
          metadata['avatarUrl']?.toString(),
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
    if (Env.hasSupabase) {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        return await _fetchProfile(session.user.id, session.user.email ?? '');
      }
      return const AuthState.unauthenticated();
    } else {
      final userData = LocalStorageService.currentUserData;
      if (userData != null) {
        return AuthState.authenticated(LocalUser.fromJson(userData));
      }
      return const AuthState.unauthenticated();
    }
  }

  Future<AuthState> _fetchProfile(String uid, String email) async {
    try {
      final res = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();
      if (res != null) {
        final user = LocalUser(
          id: uid,
          email: email,
          // profiles uses full_name, not name
          name: res['full_name']?.toString() ?? 'Usuario',
          role: res['role']?.toString() ?? 'student',
        );
        return AuthState.authenticated(user);
      }
      // Profile doesn't exist yet — safe fallback (student by default)
      final fallbackUser =
          LocalUser(id: uid, email: email, name: 'Usuario', role: 'student');
      return AuthState.authenticated(fallbackUser);
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return AuthState.unauthenticated('Error fetching profile: $e');
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncData(AuthState.loading());

    try {
      if (Env.hasSupabase) {
        final res = await Supabase.instance.client.auth
            .signInWithPassword(email: email, password: password);
        if (res.session != null) {
          final authState =
              await _fetchProfile(res.user!.id, res.user!.email ?? email);
          state = AsyncData(authState);
          return null;
        }
        state = const AsyncData(
            AuthState.unauthenticated('Error desconocido al iniciar sesión'));
        return 'Error desconocido al iniciar sesión';
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        final user = LocalStorageService.findUserByEmail(email);

        if (user == null) {
          state = const AsyncData(
              AuthState.unauthenticated('Usuario no encontrado'));
          return 'Usuario no encontrado';
        }

        final storedPassword = user['password']?.toString() ?? '';
        if (storedPassword != password) {
          state = const AsyncData(
              AuthState.unauthenticated('Contraseña incorrecta'));
          return 'Contraseña incorrecta';
        }

        await SampleData.initializeSampleData();

        final localUser = LocalUser.fromJson(user);
        await LocalStorageService.setCurrentUserData(localUser.toJson());

        state = AsyncData(AuthState.authenticated(localUser));
        return null;
      }
    } catch (e) {
      state = AsyncData(AuthState.unauthenticated(e.toString()));
      return e.toString();
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
      if (Env.hasSupabase) {
        final res = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {'name': name, 'role': role},
        );
        if (res.user != null) {
          try {
            // Insert into 'profiles' using the real column names
            await Supabase.instance.client.from('profiles').upsert({
              'id': res.user!.id,
              'full_name': name,
              'role': role,
            });
          } catch (profileErr) {
            debugPrint('Profile insert warning: $profileErr');
          }

          final authState = await _fetchProfile(res.user!.id, email);
          state = AsyncData(authState);
          return null;
        }
        state = const AsyncData(
            AuthState.unauthenticated('Error al registrar usuario'));
        return 'Error al registrar usuario';
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
        final existing = LocalStorageService.findUserByEmail(email);
        if (existing != null) {
          state = const AsyncData(
              AuthState.unauthenticated('Este correo ya está registrado'));
          return 'Este correo ya está registrado';
        }

        final userId = DateTime.now().millisecondsSinceEpoch.toString();
        final newUser = {
          'id': userId,
          'email': email.toLowerCase(),
          'name': name,
          'password': password,
          'role': role,
        };

        await LocalStorageService.addUser(newUser);

        final stats = StatisticsModel.createNew(userId);
        await LocalStorageService.setUserStatistics(stats.toJson());

        await SampleData.initializeSampleData();

        final localUser = LocalUser.fromJson(newUser);
        await LocalStorageService.setCurrentUserData(localUser.toJson());

        state = AsyncData(AuthState.authenticated(localUser));
        return null;
      }
    } catch (e) {
      state = AsyncData(AuthState.unauthenticated(e.toString()));
      return e.toString();
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return null;
  }

  Future<void> signOut() async {
    if (Env.hasSupabase) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
    }
    await LocalStorageService.clearCurrentUser();
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

    await LocalStorageService.setCurrentUserData(updatedUser.toJson());
    state = AsyncData(AuthState.authenticated(updatedUser));
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
