import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../models/statistics.dart';
import '../repositories/user_statistics_repository.dart';
import '../utils/streak_messages.dart';

class UserStatisticsState {
  final StatisticsModel? statistics;
  final bool isLoading;
  final String? error;
  final String? favoriteCategoryName;
  final int tasksCompletedThisWeek;
  final int totalNotes;
  final int notesCreatedThisWeek;
  final int eventsThisWeek;
  final int totalEvents;
  final int dailyCompletedTasks;
  final List<CategoryTaskCount> categoryTaskCounts;
  /// Tareas completadas por día esta semana: índice 0=Lun … 6=Dom
  final List<int> weeklyDailyCompletions;

  const UserStatisticsState({
    this.statistics,
    this.isLoading = false,
    this.error,
    this.favoriteCategoryName,
    this.tasksCompletedThisWeek = 0,
    this.totalNotes = 0,
    this.notesCreatedThisWeek = 0,
    this.eventsThisWeek = 0,
    this.totalEvents = 0,
    this.dailyCompletedTasks = 0,
    this.categoryTaskCounts = const [],
    this.weeklyDailyCompletions = const [0, 0, 0, 0, 0, 0, 0],
  });

  bool get hasStreak => (statistics?.racha ?? 0) > 0;
  int get currentStreak => statistics?.racha ?? 0;
  int get bestStreak => statistics?.bestStreak ?? 0;
  int get totalTasks => statistics?.totalTasks ?? 0;
  int get completedTasks => statistics?.completedTasks ?? 0;
  int get dailyGoal => statistics?.dailyGoal ?? 5;
  double get dailyProgress => dailyGoal > 0 ? (dailyCompletedTasks / dailyGoal).clamp(0.0, 1.0) : 0.0;
  bool get dailyGoalMet => dailyCompletedTasks >= dailyGoal;

  /// Cuántos días esta semana se completó al menos una tarea
  int get activeDaysThisWeek => weeklyDailyCompletions.where((c) => c > 0).length;

  String get streakMessage => getStreakMessage(currentStreak);

  double get completionPercentage {
    if (totalTasks == 0) return 0.0;
    return (completedTasks / totalTasks).clamp(0.0, 1.0);
  }

  UserStatisticsState copyWith({
    StatisticsModel? statistics,
    bool? isLoading,
    String? error,
    String? favoriteCategoryName,
    int? tasksCompletedThisWeek,
    int? totalNotes,
    int? notesCreatedThisWeek,
    int? eventsThisWeek,
    int? totalEvents,
    int? dailyCompletedTasks,
    List<CategoryTaskCount>? categoryTaskCounts,
    List<int>? weeklyDailyCompletions,
  }) {
    return UserStatisticsState(
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      favoriteCategoryName: favoriteCategoryName ?? this.favoriteCategoryName,
      tasksCompletedThisWeek: tasksCompletedThisWeek ?? this.tasksCompletedThisWeek,
      totalNotes: totalNotes ?? this.totalNotes,
      notesCreatedThisWeek: notesCreatedThisWeek ?? this.notesCreatedThisWeek,
      eventsThisWeek: eventsThisWeek ?? this.eventsThisWeek,
      totalEvents: totalEvents ?? this.totalEvents,
      dailyCompletedTasks: dailyCompletedTasks ?? this.dailyCompletedTasks,
      categoryTaskCounts: categoryTaskCounts ?? this.categoryTaskCounts,
      weeklyDailyCompletions: weeklyDailyCompletions ?? this.weeklyDailyCompletions,
    );
  }
}

class CategoryTaskCount {
  final int categoryId;
  final String categoryName;
  final int completedCount;

  const CategoryTaskCount({
    required this.categoryId,
    required this.categoryName,
    required this.completedCount,
  });
}

class UserStatisticsNotifier extends AsyncNotifier<UserStatisticsState> {
  late final UserStatisticsRepository _repository;

  @override
  Future<UserStatisticsState> build() async {
    _repository = UserStatisticsRepository();
    return _loadStatistics();
  }

  Future<UserStatisticsState> _loadStatistics() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      return const UserStatisticsState(isLoading: false, error: 'Usuario no encontrado');
    }

    // ── Datos críticos: statistics record + task counts ─────────────────────
    StatisticsModel stats;
    try {
      var found = await _repository.getByUserId(user.id);

      if (found == null) {
        found = StatisticsModel.createNew(user.id);
        found = await _repository.create(found);
      }

      // Sincronizar totalTasks/completedTasks directo desde la tabla tasks
      final counts = await _repository.getTaskCounts(user.id);
      if (found.totalTasks != counts.total || found.completedTasks != counts.completed) {
        found = found.copyWith(
          totalTasks: counts.total,
          completedTasks: counts.completed,
        );
        await _repository.update(found);
      }

      stats = found;
    } catch (e) {
      return UserStatisticsState(isLoading: false, error: e.toString());
    }

    // ── Datos opcionales: cada uno con fallback independiente ────────────────
    final dailyCompleted = await _getDailyCompletedTasks(user.id)
        .catchError((_) => 0);

    final categoryCounts = await _getCategoryTaskCounts(user.id)
        .catchError((_) => <CategoryTaskCount>[]);

    final categoryName =
        categoryCounts.isNotEmpty ? categoryCounts.first.categoryName : null;

    // Actualizar favoriteCategory en DB si cambió (best-effort)
    final favCatId =
        categoryCounts.isNotEmpty ? categoryCounts.first.categoryId : null;
    if (favCatId != stats.favoriteCategory) {
      stats = stats.copyWith(favoriteCategory: favCatId);
      _repository.update(stats); // fire-and-forget, no await
    }

    final tasksThisWeek =
        await _repository.getTasksCompletedThisWeek(user.id).catchError((_) => 0);

    final weeklyDaily =
        await _repository.getWeeklyDailyCompletions(user.id).catchError((_) => List.filled(7, 0));

    final totalNotes =
        await _repository.getNotesCount(user.id).catchError((_) => 0);

    final notesThisWeek =
        await _repository.getNotesCreatedThisWeek(user.id).catchError((_) => 0);

    final eventsThisWeek =
        await _getEventsThisWeek(user.id).catchError((_) => 0);

    final totalEvents =
        await _repository.getTotalEventsCount(user.id).catchError((_) => 0);

    return UserStatisticsState(
      statistics: stats,
      isLoading: false,
      dailyCompletedTasks: dailyCompleted,
      categoryTaskCounts: categoryCounts,
      favoriteCategoryName: categoryName,
      tasksCompletedThisWeek: tasksThisWeek,
      weeklyDailyCompletions: weeklyDaily,
      totalNotes: totalNotes,
      notesCreatedThisWeek: notesThisWeek,
      eventsThisWeek: eventsThisWeek,
      totalEvents: totalEvents,
    );
  }

  Future<int> _getDailyCompletedTasks(String userId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final response = await _client
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .eq('completed', true)
        .gte('updated_at', today.toIso8601String())
        .lt('updated_at', tomorrow.toIso8601String());

    return (response as List).length;
  }

  Future<List<CategoryTaskCount>> _getCategoryTaskCounts(String userId) async {
    final tasks = await _client
        .from('tasks')
        .select('category_id')
        .eq('user_id', userId)
        .eq('completed', true);

    final Map<int, int> categoryCompleted = {};
    for (final task in tasks) {
      final categoryId = task['category_id'] as int?;
      if (categoryId == null) continue;
      categoryCompleted[categoryId] = (categoryCompleted[categoryId] ?? 0) + 1;
    }

    if (categoryCompleted.isEmpty) return [];

    final categories = await _client
        .from('categories')
        .select('id, name')
        .eq('user_id', userId);

    final categoryMap = {for (var c in categories) c['id'] as int: c['name'] as String};

    return categoryCompleted.entries
        .map((e) => CategoryTaskCount(
              categoryId: e.key,
              categoryName: categoryMap[e.key] ?? 'Sin categoría',
              completedCount: e.value,
            ))
        .toList()
      ..sort((a, b) => b.completedCount.compareTo(a.completedCount));
  }

  Future<int> _getEventsThisWeek(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endDate = startDate.add(const Duration(days: 7));

    final response = await _client
        .from('events')
        .select('id')
        .eq('user_id', userId)
        .gte('start_date', startDate.toIso8601String())
        .lt('start_date', endDate.toIso8601String());

    return (response as List).length;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _loadStatistics());
  }

  /// Llamado cuando se completa una tarea. Actualiza racha al estilo Duolingo:
  /// la racha sube sólo cuando se cumple la meta diaria por primera vez en el día.
  Future<void> onTaskCompleted() async {
    final currentState = state.value;
    if (currentState?.statistics == null) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      var stats = currentState!.statistics!;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // dailyCompletedTasks no incluye la tarea que se acaba de completar todavía
      final prevDailyCount = currentState.dailyCompletedTasks;
      final newDailyCount = prevDailyCount + 1;
      final goalJustMet = newDailyCount >= stats.dailyGoal && prevDailyCount < stats.dailyGoal;

      int newRacha = stats.racha;
      DateTime? newLastRachaDate = stats.lastRachaDate;

      if (goalJustMet) {
        if (stats.lastRachaDate == null) {
          // Primera vez que se cumple la meta
          newRacha = 1;
          newLastRachaDate = today;
        } else {
          final lastDate = DateTime(
            stats.lastRachaDate!.year,
            stats.lastRachaDate!.month,
            stats.lastRachaDate!.day,
          );
          final daysDiff = today.difference(lastDate).inDays;

          if (daysDiff == 0) {
            // Ya se contó hoy — no hacer nada
          } else if (daysDiff == 1) {
            // Día consecutivo — extender racha
            newRacha = stats.racha + 1;
            newLastRachaDate = today;
          } else {
            // Hubo un salto — empezar racha nueva
            newRacha = 1;
            newLastRachaDate = today;
          }
        }
      }

      final newBestStreak = newRacha > stats.bestStreak ? newRacha : stats.bestStreak;

      // Solo incrementar completedTasks; totalTasks se mantiene desde onTaskCreated
      final updatedStats = stats.copyWith(
        completedTasks: stats.completedTasks + 1,
        racha: newRacha,
        lastRachaDate: newLastRachaDate,
        bestStreak: newBestStreak,
      );

      await _repository.update(updatedStats);
      await refresh();
    } catch (_) {
      // Silently fail — no crashear el flujo de completar tarea
    }
  }

  Future<void> onTaskCreated() async {
    final currentState = state.value;
    if (currentState?.statistics == null) return;

    try {
      final stats = currentState!.statistics!;
      final updatedStats = stats.copyWith(
        totalTasks: stats.totalTasks + 1,
      );
      await _repository.update(updatedStats);
      await refresh();
    } catch (_) {}
  }

  Future<void> setDailyGoal(int newGoal) async {
    final currentState = state.value;
    if (currentState?.statistics == null) return;

    try {
      final stats = currentState!.statistics!;
      await _repository.update(stats.copyWith(dailyGoal: newGoal));
      await refresh();
    } catch (_) {}
  }

  /// Verifica al abrir la app si se perdió un día y resetea la racha.
  Future<void> checkAndResetStreakIfNeeded() async {
    final currentState = state.value;
    if (currentState?.statistics == null) return;

    final stats = currentState!.statistics!;
    if (stats.racha == 0 || stats.lastRachaDate == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      stats.lastRachaDate!.year,
      stats.lastRachaDate!.month,
      stats.lastRachaDate!.day,
    );
    final daysDiff = today.difference(lastDate).inDays;

    // Si el último día con meta cumplida fue hace más de 1 día, la racha se pierde
    if (daysDiff > 1) {
      await _repository.update(stats.copyWith(racha: 0));
      await refresh();
    }
  }
}

final userStatisticsProvider = AsyncNotifierProvider<UserStatisticsNotifier, UserStatisticsState>(
  UserStatisticsNotifier.new,
);

extension _SupabaseAccess on UserStatisticsNotifier {
  SupabaseClient get _client => Supabase.instance.client;
}
