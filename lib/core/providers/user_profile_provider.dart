import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import 'auth_provider.dart';
import '../../models/user.dart';

import '../database/database_service.dart';

class UserProfileNotifier extends AsyncNotifier<UserModel> {
  @override
  Future<UserModel> build() => _fetch();

  Future<UserModel> _fetch() async {
    final authUser = ref.read(currentUserProvider);
    if (authUser == null) return UserModel.mock;

    final raw = await DatabaseService.query(
      'users',
      where: 'id = ?',
      whereArgs: [authUser.id],
    );

    if (raw.isEmpty) return UserModel.fromLocalUser(authUser);

    final d = raw.first;
    return UserModel(
      id: d['id']?.toString() ?? '',
      name: d['name']?.toString() ?? '',
      email: d['email']?.toString() ?? '',
      role: (d['role']?.toString() == 'teacher')
          ? UserRole.teacher
          : UserRole.student,
      career: d['career']?.toString(),
      bio: d['bio']?.toString(),
      university: d['university']?.toString(),
      semester: d['semester'] as int?,
      avatarUrl: d['avatarUrl']?.toString(),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final userId = state.value?.id;
    if (userId == null) return;

    await DatabaseService.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [userId],
    );

    state = await AsyncValue.guard(_fetch);

    // Also update current user in auth provider if needed
    // (This might require a method in currentUserProvider notifier)
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserModel>(
  UserProfileNotifier.new,
);
