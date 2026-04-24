import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';
import '../../models/statistics.dart';

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
    final userData = LocalStorageService.currentUserData;
    if (userData != null) {
      return AuthState.authenticated(LocalUser.fromJson(userData));
    }
    return const AuthState.unauthenticated();
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncData(AuthState.loading());
    await Future.delayed(const Duration(milliseconds: 300));

    final user = LocalStorageService.findUserByEmail(email);
    if (user == null) {
      state =
          const AsyncData(AuthState.unauthenticated('Usuario no encontrado'));
      return 'Usuario no encontrado';
    }

    final storedPassword = user['password']?.toString() ?? '';
    if (storedPassword != password) {
      state =
          const AsyncData(AuthState.unauthenticated('Contraseña incorrecta'));
      return 'Contraseña incorrecta';
    }

    final localUser = LocalUser.fromJson(user);
    await LocalStorageService.setCurrentUserData(localUser.toJson());
    state = AsyncData(AuthState.authenticated(localUser));
    return null;
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    state = const AsyncData(AuthState.loading());
    await Future.delayed(const Duration(milliseconds: 300));

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

    final localUser = LocalUser.fromJson(newUser);
    await LocalStorageService.setCurrentUserData(localUser.toJson());
    state = AsyncData(AuthState.authenticated(localUser));
    return null;
  }

  Future<String?> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return null;
  }

  Future<void> signOut() async {
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
