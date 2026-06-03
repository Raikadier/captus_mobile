import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_service.dart';
import 'auth_provider.dart';
import '../../models/group.dart';

class GroupsService {
  Future<List<GroupModel>> fetchAll(String userId) async {
    final raw = await DatabaseService.query(
      'groups',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return raw.map((g) => GroupModel.fromJson(g)).toList();
  }

  Future<void> joinGroup(String groupId) async {
    await DatabaseService.update(
      'groups',
      {'isJoined': 1},
      where: 'id = ?',
      whereArgs: [groupId],
    );
  }

  Future<void> leaveGroup(String groupId) async {
    await DatabaseService.update(
      'groups',
      {'isJoined': 0},
      where: 'id = ?',
      whereArgs: [groupId],
    );
  }
}

final groupsServiceProvider = Provider<GroupsService>((ref) {
  return GroupsService();
});

final groupsProvider = FutureProvider.autoDispose<List<GroupModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  final userId = user?.id ?? '';

  return ref.read(groupsServiceProvider).fetchAll(userId);
});

final myGroupsProvider =
    Provider.autoDispose<AsyncValue<List<GroupModel>>>((ref) {
  return ref.watch(groupsProvider).whenData(
        (groups) => groups.where((g) => g.isJoined).toList(),
      );
});
