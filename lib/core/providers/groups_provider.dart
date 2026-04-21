import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';

class GroupModel {
  final String id;
  final String name;
  final String? description;
  final int memberCount;
  final bool isJoined;
  final DateTime createdAt;

  const GroupModel({
    required this.id,
    required this.name,
    this.description,
    required this.memberCount,
    required this.isJoined,
    required this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      memberCount: json['memberCount'] as int? ?? 0,
      isJoined: json['isJoined'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class GroupsService {
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

final groupsProvider = FutureProvider.autoDispose<List<GroupModel>>((ref) {
  return ref.read(groupsServiceProvider).fetchAll();
});

final myGroupsProvider =
    Provider.autoDispose<AsyncValue<List<GroupModel>>>((ref) {
  return ref.watch(groupsProvider).whenData(
        (groups) => groups.where((g) => g.isJoined).toList(),
      );
});
