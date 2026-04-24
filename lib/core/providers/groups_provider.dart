import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';

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
    // Backend returns members as int count or as a List
    final membersRaw = json['members'];
    final memberCount = membersRaw is int
        ? membersRaw
        : (membersRaw is List ? membersRaw.length : (json['memberCount'] as int? ?? 0));

    return GroupModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      memberCount: memberCount,
      // /my-groups only returns groups the user belongs to
      isJoined: json['isJoined'] as bool? ?? true,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }
}

class GroupsService {
  Future<List<GroupModel>> fetchAll() async {
    final res =
        await ApiClient.instance.get<dynamic>('/academic-groups/my-groups');
    final raw = res.data is List
        ? res.data as List
        : (res.data is Map ? (res.data['data'] as List? ?? []) : []);
    return raw
        .map((g) => GroupModel.fromJson(g as Map<String, dynamic>))
        .toList();
  }
}

final groupsServiceProvider =
    Provider<GroupsService>((_) => GroupsService());

final groupsProvider = FutureProvider.autoDispose<List<GroupModel>>((ref) {
  return ref.read(groupsServiceProvider).fetchAll();
});

final myGroupsProvider =
    Provider.autoDispose<AsyncValue<List<GroupModel>>>((ref) {
  return ref.watch(groupsProvider).whenData(
        (groups) => groups.where((g) => g.isJoined).toList(),
      );
});
