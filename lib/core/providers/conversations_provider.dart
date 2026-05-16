import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import 'auth_provider.dart';

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
  Future<List<ConversationItem>> build() {
    // Watch the current user so this provider rebuilds (and the AI conversation
    // list resets) whenever the authenticated user changes.
    final user = ref.watch(currentUserProvider);
    if (user == null) return Future.value([]);
    return _fetch();
  }

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

  /// Delete a single conversation from server and remove it from local state.
  Future<void> delete(String id) async {
    // Optimistic remove — if the server call fails we restore the item.
    final previous = state;
    state = state.whenData(
      (list) => list.where((c) => c.id != id).toList(),
    );
    try {
      await ApiClient.instance.delete<dynamic>('/ai/conversations/$id');
    } catch (_) {
      // Restore on failure.
      state = previous;
      rethrow;
    }
  }

  /// Delete ALL conversations for the current user.
  Future<void> deleteAll() async {
    final previous = state;
    state = const AsyncData([]);
    try {
      await ApiClient.instance.delete<dynamic>('/ai/conversations');
    } catch (_) {
      state = previous;
      rethrow;
    }
  }
}

final conversationsProvider =
    AsyncNotifierProvider<ConversationsNotifier, List<ConversationItem>>(
  ConversationsNotifier.new,
);
