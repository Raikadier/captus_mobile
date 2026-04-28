import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../database/database_service.dart';
import 'auth_provider.dart';

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
    final rawDate = json['start_date'] ?? json['date'];

    return CalendarEvent(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      date: DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now(),
      type: json['type']?.toString() ?? 'event',
      colorIndex: (json['colorIndex'] as int?) ?? 0,
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
  final _uuid = const Uuid();

  Future<List<CalendarEvent>> fetchAll(String userId) async {
    final raw = await DatabaseService.query(
      'events',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return raw.map((e) => CalendarEvent.fromJson(e)).toList();
  }

  Future<CalendarEvent> create(
      Map<String, dynamic> payload, String userId) async {
    final id = _uuid.v4();

    final data = {
      'id': id,
      'title': payload['title'],
      'description': payload['description'],
      'date': payload['start_date'] ?? payload['date'],
      'type': payload['type'] ?? 'event',
      'colorIndex': payload['colorIndex'] ?? 0,
      'courseId': payload['courseId'],
      'userId': userId,
    };

    await DatabaseService.insert('events', data);

    return CalendarEvent.fromJson(data);
  }

  Future<void> delete(String eventId) async {
    await DatabaseService.delete(
      'events',
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }
}

final eventsServiceProvider = Provider<EventsService>((ref) {
  return EventsService();
});

final eventsProvider = FutureProvider.autoDispose<List<CalendarEvent>>((ref) {
  final user = ref.watch(currentUserProvider);
  final userId = user?.id ?? '';

  return ref.read(eventsServiceProvider).fetchAll(userId);
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
