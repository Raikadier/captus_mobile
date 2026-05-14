import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/statistics.dart';

class UserStatisticsRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<StatisticsModel?> getByUserId(String userId) async {
    final response = await _client
        .from('statistics')
        .select()
        .eq('id_User', userId)
        .maybeSingle();

    if (response == null) return null;
    return StatisticsModel.fromJson(response);
  }

  Future<StatisticsModel> create(StatisticsModel stats) async {
    final response = await _client
        .from('statistics')
        .insert(stats.toJson())
        .select()
        .single();
    return StatisticsModel.fromJson(response);
  }

  Future<StatisticsModel?> update(StatisticsModel stats) async {
    if (stats.idStatistics == null) return null;

    await _client
        .from('statistics')
        .update(stats.toJson())
        .eq('id_Statistics', stats.idStatistics!);

    return getByUserId(stats.idUser);
  }

  Future<void> delete(int statsId) async {
    await _client.from('statistics').delete().eq('id_Statistics', statsId);
  }

  /// Returns (total, completed) counts from tasks table directly — avoids drift.
  Future<({int total, int completed})> getTaskCounts(String userId) async {
    final all = await _client
        .from('tasks')
        .select('completed')
        .eq('user_id', userId);

    final list = all as List;
    final total = list.length;
    final completed = list.where((t) => t['completed'] == true).length;
    return (total: total, completed: completed);
  }

  Future<Map<int, int>> getCategoryTaskCounts(String userId) async {
    final tasks = await _client
        .from('tasks')
        .select('category_id, completed')
        .eq('user_id', userId)
        .eq('completed', true);

    final Map<int, int> categoryCompleted = {};
    for (final task in tasks) {
      final categoryId = task['category_id'] as int?;
      if (categoryId == null) continue;
      categoryCompleted[categoryId] = (categoryCompleted[categoryId] ?? 0) + 1;
    }

    return categoryCompleted;
  }

  Future<int> getTasksCompletedThisWeek(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    final response = await _client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .eq('completed', true)
        .gte('updated_at', startDate.toIso8601String());

    return (response as List).length;
  }

  /// Returns a 7-element list [Mon..Sun] with completed-task counts for each day this week.
  Future<List<int>> getWeeklyDailyCompletions(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endDate = startDate.add(const Duration(days: 7));

    final tasks = await _client
        .from('tasks')
        .select('updated_at')
        .eq('user_id', userId)
        .eq('completed', true)
        .gte('updated_at', startDate.toIso8601String())
        .lt('updated_at', endDate.toIso8601String());

    final List<int> daily = List.filled(7, 0);
    for (final task in tasks) {
      final raw = task['updated_at'];
      if (raw == null) continue;
      final dt = DateTime.tryParse(raw.toString());
      if (dt == null) continue;
      final idx = dt.toLocal().weekday - 1; // Mon=0 … Sun=6
      if (idx >= 0 && idx < 7) daily[idx]++;
    }
    return daily;
  }

  Future<int> getNotesCount(String userId) async {
    final response = await _client
        .from('notes')
        .select('id')
        .eq('user_id', userId);

    return (response as List).length;
  }

  Future<int> getNotesCreatedThisWeek(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    final response = await _client
        .from('notes')
        .select('id')
        .eq('user_id', userId)
        .gte('created_at', startDate.toIso8601String());

    return (response as List).length;
  }

  Future<int> getTotalEventsCount(String userId) async {
    final response = await _client
        .from('events')
        .select('id')
        .eq('user_id', userId);

    return (response as List).length;
  }
}
