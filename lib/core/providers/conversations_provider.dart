import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';

class ConversationItem {
  final String id;
  final String title;
  final DateTime updatedAt;

  const ConversationItem({
    required this.id,
    required this.title,
    required this.updatedAt,
  });

  factory ConversationItem.fromJson(Map<String, dynamic> json) =>
      ConversationItem(
        id: json['id']?.toString() ?? '',
        title: (json['title'] as String?)?.trim().isNotEmpty == true
            ? json['title'] as String
            : 'Conversación',
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class ConversationsNotifier
    extends AsyncNotifier<List<ConversationItem>> {
  @override
  Future<List<ConversationItem>> build() => _fetch();

  Future<List<ConversationItem>> _fetch() async {
    final res =
        await ApiClient.instance.get<List<dynamic>>('/ai/conversations');
    final raw = res.data is List ? res.data as List<dynamic> : <dynamic>[];
    return raw
        .map((e) => ConversationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}

final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<ConversationItem>>(
  ConversationsNotifier.new,
);
