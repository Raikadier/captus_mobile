import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

class CalendarEvent {
  final int? id;
  final String userId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String type;
  final bool isPast;
  final bool notify;
  final Map<String, dynamic>? metadata;

  const CalendarEvent({
    this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
    required this.type,
    required this.isPast,
    required this.notify,
    this.metadata,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    final startDate = DateTime.parse(json['start_date'] as String);
    final now = DateTime.now();
    final isPast = startDate.isBefore(DateTime(now.year, now.month, now.day));

    return CalendarEvent(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startDate: startDate,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      type: json['type'] as String,
      isPast: json['is_past'] as bool? ?? isPast,
      notify: json['notify'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'type': type,
        'is_past': isPast,
        'notify': notify,
        'metadata': metadata ?? {},
      };

  CalendarEvent copyWith({
    int? id,
    String? userId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type,
    bool? isPast,
    bool? notify,
    Map<String, dynamic>? metadata,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      isPast: isPast ?? this.isPast,
      notify: notify ?? this.notify,
      metadata: metadata ?? this.metadata,
    );
  }
}

class EventsService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<CalendarEvent>> fetchAll(String userId) async {
    final response = await _client
        .from('events')
        .select()
        .eq('user_id', userId)
        .order('start_date', ascending: true);

    return (response as List)
        .map((json) => CalendarEvent.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<CalendarEvent> create({
    required String userId,
    required String title,
    String? description,
    required DateTime startDate,
    DateTime? endDate,
    required String type,
    required bool notify,
  }) async {
    final now = DateTime.now();
    final nowStr = now.toIso8601String();
    final today = DateTime(now.year, now.month, now.day);
    final isPast = startDate.isBefore(today);

    final data = {
      'user_id': userId,
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'type': type,
      'is_past': isPast,
      'notify': notify,
      'metadata': <String, dynamic>{},
      'created_at': nowStr,
      'updated_at': nowStr,
    };

    final response = await _client
        .from('events')
        .insert(data)
        .select()
        .single();

    return CalendarEvent.fromJson(response);
  }

  Future<CalendarEvent?> update(int eventId, Map<String, dynamic> updates) async {
    final updateData = Map<String, dynamic>.from(updates);
    updateData['updated_at'] = DateTime.now().toIso8601String();

    if (updateData.containsKey('start_date')) {
      final startDate = DateTime.parse(updateData['start_date'] as String);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      updateData['is_past'] = startDate.isBefore(today);
    }

    await _client
        .from('events')
        .update(updateData)
        .eq('id', eventId);

    final response = await _client
        .from('events')
        .select()
        .eq('id', eventId)
        .maybeSingle();

    if (response == null) return null;
    return CalendarEvent.fromJson(response);
  }

  Future<void> delete(int eventId) async {
    await _client.from('events').delete().eq('id', eventId);
  }
}

final eventsServiceProvider = Provider<EventsService>((ref) => EventsService());

class EventsNotifier extends AsyncNotifier<List<CalendarEvent>> {
  @override
  Future<List<CalendarEvent>> build() {
    final user = ref.watch(currentUserProvider);
    if (user == null) return Future.value([]);
    return ref.read(eventsServiceProvider).fetchAll(user.id);
  }

  Future<void> refresh() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(eventsServiceProvider).fetchAll(user.id),
    );
  }

  Future<CalendarEvent?> create({
    required String title,
    String? description,
    required DateTime startDate,
    DateTime? endDate,
    required String type,
    required bool notify,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return null;

    try {
      final event = await ref.read(eventsServiceProvider).create(
            userId: user.id,
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate,
            type: type,
            notify: notify,
          );

      state = state.whenData((events) => [event, ...events]);
      return event;
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> updateEvent(int eventId, Map<String, dynamic> updates) async {
    try {
      final updated = await ref.read(eventsServiceProvider).update(eventId, updates);
      if (updated != null) {
        state = state.whenData(
          (events) => events.map((e) => e.id == eventId ? updated : e).toList(),
        );
      }
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> delete(int eventId) async {
    state = state.whenData(
      (events) => events.where((e) => e.id != eventId).toList(),
    );
    try {
      await ref.read(eventsServiceProvider).delete(eventId);
    } catch (e) {
      await refresh();
      rethrow;
    }
  }
}

final eventsNotifierProvider =
    AsyncNotifierProvider<EventsNotifier, List<CalendarEvent>>(EventsNotifier.new);

final todayEventsProvider = Provider.autoDispose<AsyncValue<List<CalendarEvent>>>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  return ref.watch(eventsNotifierProvider).whenData(
        (events) => events.where((e) {
          final eventDate = DateTime(e.startDate.year, e.startDate.month, e.startDate.day);

          return eventDate.isAtSameMomentAs(today) ||
              (eventDate.isAfter(today) && eventDate.isBefore(tomorrow));
        }).toList(),
      );
});

final eventsByDateProvider =
    Provider.family<List<CalendarEvent>, DateTime>((ref, date) {
  final eventsAsync = ref.watch(eventsNotifierProvider);
  return eventsAsync.maybeWhen(
    data: (events) {
      final targetDate = DateTime(date.year, date.month, date.day);
      return events.where((e) {
        final eventDate = DateTime(e.startDate.year, e.startDate.month, e.startDate.day);
        return eventDate.isAtSameMomentAs(targetDate);
      }).toList();
    },
    orElse: () => [],
  );
});