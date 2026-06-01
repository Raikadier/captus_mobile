import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../models/group.dart';
import '../services/api_client.dart';
import 'auth_provider.dart';

// ─── myGroupsProvider ────────────────────────────────────────────────────────

/// Fetches the groups the authenticated user belongs to via
/// `GET /groups/my-groups`.
final myGroupsProvider =
    FutureProvider.autoDispose<List<GroupModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  try {
    final res = await ApiClient.instance.get<dynamic>('/groups/my-groups');
    final raw = res.data;
    if (raw is! List) return [];
    return raw
        .map((item) =>
            GroupModel.fromApiJson(item as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  }
});

// ─── groupsByCourseProvider ──────────────────────────────────────────────────

/// Fetches groups for a specific course via `GET /groups/course/:id`.
final groupsByCourseProvider =
    FutureProvider.autoDispose.family<List<GroupModel>, String>((ref, courseId) async {
  try {
    final res =
        await ApiClient.instance.get<dynamic>('/groups/course/$courseId');
    final raw = res.data;
    if (raw is! List) return [];
    return raw
        .map((item) =>
            GroupModel.fromApiJson(item as Map<String, dynamic>))
        .toList();
  } on DioException catch (e) {
    throw ApiException.fromDio(e);
  }
});

// ─── createGroupProvider (notifier) ─────────────────────────────────────────

class CreateGroupNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createGroup({
    required String name,
    required String courseId,
    String? description,
  }) async {
    try {
      await ApiClient.instance.post('/groups', data: {
        'name': name,
        'course_id': courseId,
        'description': description ?? '',
      });
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
    ref.invalidate(myGroupsProvider);
  }
}

final createGroupNotifierProvider =
    AsyncNotifierProvider<CreateGroupNotifier, void>(
        CreateGroupNotifier.new);
