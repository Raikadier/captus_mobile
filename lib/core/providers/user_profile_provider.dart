import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';
import '../../models/user.dart';

class UserProfileNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() => _fetch();

  Future<UserModel?> _fetch() async {
    final authState = ref.watch(authProvider).asData?.value;
    if (authState == null || !authState.isAuthenticated || authState.user == null) {
      return null;
    }

    final authUser = authState.user!;

    try {
      final res = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      if (res == null) return null;

      return UserModel(
        id: res['id']?.toString() ?? '',
        name: res['name']?.toString() ?? 'Usuario',
        email: res['email']?.toString() ?? authUser.email,
        role: res['role']?.toString() == 'teacher'
            ? UserRole.teacher
            : UserRole.student,
        career: res['career']?.toString(),
        bio: res['bio']?.toString(),
        university: res['university']?.toString(),
        semester: res['semester'] as int?,
        avatarUrl: res['avatarUrl']?.toString(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final user = state.value;
    if (user == null) return;

    await Supabase.instance.client
        .from('users')
        .update(updates)
        .eq('id', user.id);

    state = await AsyncValue.guard(_fetch);
    
    // Invalidate auth provider to sync local user if needed
    ref.invalidate(authProvider);
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserModel?>(
  UserProfileNotifier.new,
);
