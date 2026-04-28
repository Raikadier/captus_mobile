import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< Updated upstream
import '../services/local_storage_service.dart';
=======
import '../database/database_service.dart';
import 'auth_provider.dart';
>>>>>>> Stashed changes

class GroupModel {
  final String id;
  final String name;
  final String? description;
  final int memberCount;
  final bool isJoined;
  final String? userId;

  const GroupModel({
    required this.id,
    required this.name,
    this.description,
    this.memberCount = 0,
    this.isJoined = false,
    this.userId,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id']?.toString() ?? '',
      name: json['title']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString(),
<<<<<<< Updated upstream
      memberCount: json['memberCount'] as int? ?? 0,
      isJoined: json['isJoined'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
=======
      memberCount: (json['memberCount'] as int?) ?? 0,
      isJoined: (json['isJoined'] == 1) || (json['isJoined'] == true),
      userId: json['userId']?.toString(),
>>>>>>> Stashed changes
    );
  }
}

class GroupsService {
<<<<<<< Updated upstream
  Future<List<GroupModel>> fetchAll() async {
    final groups = LocalStorageService.groups;
    return groups.map((g) => GroupModel.fromJson(g)).toList();
  }

  Future<void> joinGroup(String groupId) async {
    final groups = LocalStorageService.groups;
    final index = groups.indexWhere((g) => g['id'] == groupId);
    if (index != -1) {
      groups[index]['isJoined'] = true;
      groups[index]['memberCount'] =
          (groups[index]['memberCount'] as int? ?? 0) + 1;
      await LocalStorageService.setGroups(groups);
    }
  }

  Future<void> leaveGroup(String groupId) async {
    final groups = LocalStorageService.groups;
    final index = groups.indexWhere((g) => g['id'] == groupId);
    if (index != -1) {
      groups[index]['isJoined'] = false;
      groups[index]['memberCount'] =
          ((groups[index]['memberCount'] as int? ?? 1) - 1).clamp(0, 9999);
      await LocalStorageService.setGroups(groups);
    }
  }
}

final groupsServiceProvider = Provider<GroupsService>(
  (ref) => GroupsService(),
);
=======
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
}

final groupsServiceProvider = Provider<GroupsService>((_) => GroupsService());
>>>>>>> Stashed changes

final groupsProvider = FutureProvider.autoDispose<List<GroupModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  return ref.read(groupsServiceProvider).fetchAll(user?.id ?? '');
});

final myGroupsProvider =
    Provider.autoDispose<AsyncValue<List<GroupModel>>>((ref) {
  return ref.watch(groupsProvider).whenData(
        (groups) => groups.where((g) => g.isJoined).toList(),
      );
});
