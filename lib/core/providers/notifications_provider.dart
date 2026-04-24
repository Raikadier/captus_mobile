import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../../models/app_notification.dart';

extension AppNotificationFromJson on AppNotification {
  static AppNotification fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: _mapType(json['type']?.toString() ?? json['event_type']?.toString()),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      isRead: json['read'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  static NotificationType _mapType(String? raw) {
    switch (raw) {
      case 'task':
      case 'reminder':
        return NotificationType.task;
      case 'academic':
      case 'course':
        return NotificationType.course;
      case 'achievement':
        return NotificationType.system;
      case 'group':
        return NotificationType.group;
      case 'ai':
        return NotificationType.ai;
      default:
        return NotificationType.system;
    }
  }
}

class NotificationsNotifier
    extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() => _fetch();

  Future<List<AppNotification>> _fetch() async {
    final res = await ApiClient.instance.get<dynamic>('/notifications');
    final raw = res.data is List
        ? res.data as List
        : (res.data is Map ? (res.data['data'] as List? ?? []) : []);
    return raw
        .map((n) =>
            AppNotificationFromJson.fromJson(n as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(String id) async {
    // Optimistic update
    state = state.whenData(
      (list) => list.map((n) {
        if (n.id == id) {
          return AppNotification(
            id: n.id,
            type: n.type,
            title: n.title,
            body: n.body,
            isRead: true,
            createdAt: n.createdAt,
            deepLink: n.deepLink,
          );
        }
        return n;
      }).toList(),
    );
    try {
      await ApiClient.instance.put<void>('/notifications/$id/read');
    } catch (_) {
      // Non-critical — optimistic update is fine even if API fails
    }
  }

  Future<void> markAllRead() async {
    state = state.whenData(
      (list) => list.map((n) => AppNotification(
            id: n.id,
            type: n.type,
            title: n.title,
            body: n.body,
            isRead: true,
            createdAt: n.createdAt,
            deepLink: n.deepLink,
          )).toList(),
    );
    // Fire individual reads in background
    final ids =
        state.value?.where((n) => !n.isRead).map((n) => n.id).toList() ?? [];
    for (final id in ids) {
      ApiClient.instance.put<void>('/notifications/$id/read').catchError((e) => throw e);
    }
  }

  void remove(String id) {
    state = state.whenData(
      (list) => list.where((n) => n.id != id).toList(),
    );
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(
  NotificationsNotifier.new,
);

final unreadCountProvider = Provider<int>((ref) {
  return ref
          .watch(notificationsProvider)
          .asData
          ?.value
          .where((n) => !n.isRead)
          .length ??
      0;
});
