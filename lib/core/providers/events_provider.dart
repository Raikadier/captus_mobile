import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';

class CalendarEvent {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final String type;
  final int colorIndex;
  final String? courseId;

  const CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.type,
    required this.colorIndex,
    this.courseId,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    // Backend uses start_date; local cache uses date
    final rawDate = json['start_date'] ?? json['date'];
    return CalendarEvent(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      date: DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now(),
      type: json['type']?.toString() ?? 'personal',
      colorIndex: json['colorIndex'] as int? ?? 0,
      courseId: json['courseId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'start_date': date.toIso8601String(),
        'type': type,
      };
}

class EventsService {
  Future<List<CalendarEvent>> fetchAll() async {
    final res =
        await ApiClient.instance.get<Map<String, dynamic>>('/events');
    final raw = res.data is Map ? (res.data!['data'] as List? ?? []) : [];
    return raw
        .map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CalendarEvent> create(Map<String, dynamic> payload) async {
    final res = await ApiClient.instance
        .post<Map<String, dynamic>>('/events', data: payload);
    final body = res.data is Map ? res.data! : <String, dynamic>{};
    final eventJson = (body['data'] as Map<String, dynamic>?) ?? body;
    return CalendarEvent.fromJson(eventJson);
  }

  Future<void> delete(String eventId) async {
    await ApiClient.instance.delete<void>('/events/$eventId');
  }
}

final eventsServiceProvider = Provider<EventsService>((_) => EventsService());

final eventsProvider = FutureProvider.autoDispose<List<CalendarEvent>>((ref) {
  return ref.read(eventsServiceProvider).fetchAll();
});

final todayEventsProvider =
    Provider.autoDispose<AsyncValue<List<CalendarEvent>>>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  return ref.watch(eventsProvider).whenData(
        (events) => events.where((e) {
          final eventDate = DateTime(e.date.year, e.date.month, e.date.day);
          return eventDate.isAtSameMomentAs(today) ||
              (eventDate.isAfter(today) && eventDate.isBefore(tomorrow));
        }).toList(),
      );
});
