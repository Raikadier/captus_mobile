import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/user.dart';
import 'auth_provider.dart';

final _supabase = Supabase.instance.client;

class UserProfileNotifier extends AsyncNotifier<UserModel> {
  @override
  Future<UserModel> build() => _fetch();

  Future<UserModel> _fetch() async {
    final authUser = ref.read(currentUserProvider);
    if (authUser == null) {
      throw Exception('Usuario no autenticado');
    }

    final row = await _supabase
        .from('users')
        .select()
        .eq('id', authUser.id)
        .maybeSingle();

    if (row == null) {
      await _supabase.from('users').insert({
        'id': authUser.id,
        'email': authUser.email,
        'name': authUser.name.isEmpty ? authUser.email : authUser.name,
        'role': authUser.role,
        'university': authUser.university,
        'carrer': authUser.career,
        'semester': authUser.semester,
        'bio': authUser.bio,
        'avatarUrl': authUser.avatarUrl ?? '',
      });
      return UserModel.fromLocalUser(authUser);
    }

    return _fromDb(row);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<UserModel> updateProfile(Map<String, dynamic> updates) async {
    final authUser = ref.read(currentUserProvider);
    if (authUser == null) {
      throw Exception('Usuario no autenticado');
    }

    final payload = <String, dynamic>{
      if (updates.containsKey('name')) 'name': updates['name'],
      if (updates.containsKey('email')) 'email': updates['email'],
      if (updates.containsKey('university')) 'university': updates['university'],
      if (updates.containsKey('career')) 'carrer': updates['career'],
      if (updates.containsKey('semester')) 'semester': updates['semester'],
      if (updates.containsKey('bio')) 'bio': updates['bio'],
      if (updates.containsKey('avatarUrl')) 'avatarUrl': updates['avatarUrl'],
      'updated_at': DateTime.now().toIso8601String(),
    };

    final row = await _supabase
        .from('users')
        .update(payload)
        .eq('id', authUser.id)
        .select()
        .single();

    final updated = _fromDb(row);
    state = AsyncData(updated);
    ref.read(authProvider.notifier).updateProfile(updated.toJson());
    return updated;
  }

  Future<String> uploadAvatar({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final authUser = ref.read(currentUserProvider);
    if (authUser == null) {
      throw Exception('Usuario no autenticado');
    }

    final safeName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final path =
        '${authUser.id}/${DateTime.now().millisecondsSinceEpoch}_$safeName';

    await _supabase.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _supabase.storage.from('avatars').getPublicUrl(path);
  }

  UserModel _fromDb(Map<String, dynamic> row) {
    final authUser = ref.read(currentUserProvider);
    final role = row['role']?.toString() ?? authUser?.role ?? 'student';
    final rawSemester = row['semester'];
    return UserModel(
      id: row['id']?.toString() ?? authUser?.id ?? '',
      name: row['name']?.toString() ?? authUser?.name ?? '',
      email: row['email']?.toString() ?? authUser?.email ?? '',
      role: role == 'teacher' ? UserRole.teacher : UserRole.student,
      university: row['university']?.toString(),
      career: row['carrer']?.toString() ?? row['career']?.toString(),
      semester: rawSemester is num ? rawSemester.toInt() : null,
      bio: row['bio']?.toString(),
      avatarUrl: row['avatarUrl']?.toString() ?? row['avatar_url']?.toString(),
      createdAt: DateTime.tryParse(row['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(row['updated_at']?.toString() ?? ''),
    );
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserModel>(
  UserProfileNotifier.new,
);
