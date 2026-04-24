import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import 'auth_provider.dart';
import '../../models/user.dart' hide UserRole;

class UserProfileNotifier extends AsyncNotifier<UserModel> {
  @override
  Future<UserModel> build() => _fetch();

  Future<UserModel> _fetch() async {
    final res =
        await ApiClient.instance.get<Map<String, dynamic>>('/users/profile');
    final data = res.data is Map
        ? ((res.data!['data'] as Map<String, dynamic>?) ?? res.data!)
        : <String, dynamic>{};
    return _fromBackend(data);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final userId = state.value?.id;
    if (userId == null) return;
    await ApiClient.instance.put<void>('/users/$userId', data: updates);
    state = await AsyncValue.guard(_fetch);
  }

  UserModel _fromBackend(Map<String, dynamic> d) {
    // Backend stores 'carrer' (misspelling) — map to mobile 'career'
    final authUser = ref.read(currentUserProvider);
    return UserModel(
      id: d['id']?.toString() ?? authUser?.id ?? '',
      name: d['name']?.toString() ?? authUser?.name ?? '',
      email: d['email']?.toString() ?? authUser?.email ?? '',
      role: d['role']?.toString() ?? authUser?.role ?? 'student',
      career: d['carrer']?.toString() ?? d['career']?.toString(),
      bio: d['bio']?.toString(),
      university: d['university']?.toString(),
      semester: d['semester'] as int?,
      avatarUrl: d['avatar_url']?.toString() ?? d['avatarUrl']?.toString(),
      createdAt: DateTime.tryParse(d['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(d['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserModel>(
  UserProfileNotifier.new,
);
