import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/api_client.dart';
import '../../../models/achievement.dart';

class AchievementsRepository {
  final SupabaseClient _db = Supabase.instance.client;

  String? get _userId => _db.auth.currentUser?.id;

  Future<List<Achievement>> fetchAchievements() async {
    final uid = _userId;
    if (uid == null) return _emptyList();

    final data = await _db
        .from('userAchievements')
        .select()
        .eq('id_User', uid);

    final userDataMap = <String, UserAchievementData>{};
    for (final item in data as List<dynamic>) {
      final d = UserAchievementData.fromJson(item as Map<String, dynamic>);
      userDataMap[d.achievementId] = d;
    }

    final achievements = kAchievements.entries.map((entry) {
      return Achievement(definition: entry.value, data: userDataMap[entry.key]);
    }).toList();

    achievements.sort((a, b) {
      if (a.isCompleted && !b.isCompleted) return -1;
      if (!a.isCompleted && b.isCompleted) return 1;
      if (a.isCompleted && b.isCompleted) {
        final aDate = a.unlockedAt ?? DateTime(0);
        final bDate = b.unlockedAt ?? DateTime(0);
        return bDate.compareTo(aDate);
      }
      return b.progressPercent.compareTo(a.progressPercent);
    });

    return achievements;
  }

  Future<AchievementStats> fetchStats() async {
    final achievements = await fetchAchievements();
    final completed = achievements.where((a) => a.isCompleted).length;
    final rate = completed / kTotalAchievements;
    return AchievementStats(
      totalAchievements: kTotalAchievements,
      completedAchievements: completed,
      completionRate: rate,
    );
  }

  // Llama al backend para recalcular logros según actividad del usuario
  Future<void> recalculate() async {
    try {
      await ApiClient.instance.post<void>('/achievements/recalculate');
    } catch (_) {
      // No crítico — la pantalla carga igual con los datos actuales en Supabase
    }
  }

  List<Achievement> _emptyList() => kAchievements.values
      .map((def) => Achievement(definition: def))
      .toList();
}
