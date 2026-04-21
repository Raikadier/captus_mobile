import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_storage_service.dart';

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
    return CalendarEvent(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      type: json['type']?.toString() ?? 'event',
      colorIndex: json['colorIndex'] as int? ?? 0,
      courseId: json['courseId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'type': type,
        'colorIndex': colorIndex,
        'courseId': courseId,
      };
}

class EventsService {
  Future<List<CalendarEvent>> fetchAll() async {
    final events = LocalStorageService.events;
    return events.map((e) => CalendarEvent.fromJson(e)).toList();
  }

  Future<CalendarEvent> create(Map<String, dynamic> payload) async {
    final event = CalendarEvent.fromJson(payload);
    await LocalStorageService.addEvent(payload);
    return event;
  }

  Future<void> delete(String eventId) async {
    await LocalStorageService.deleteEvent(eventId);
  }
}

final eventsServiceProvider = Provider<EventsService>(
  (ref) => EventsService(),
);

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
