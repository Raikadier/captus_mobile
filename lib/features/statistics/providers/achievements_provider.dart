import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/achievement.dart';
import '../repositories/achievements_repository.dart';

class AchievementsState {
  final List<Achievement> achievements;
  final AchievementStats? stats;
  final bool isLoading;
  final String? error;
  final AchievementDifficulty? activeFilter;

  const AchievementsState({
    this.achievements = const [],
    this.stats,
    this.isLoading = false,
    this.error,
    this.activeFilter,
  });

  List<Achievement> get filtered => activeFilter == null
      ? achievements
      : achievements
          .where((a) => a.definition.difficulty == activeFilter)
          .toList();

  List<Achievement> get unlocked =>
      filtered.where((a) => a.isCompleted).toList();

  List<Achievement> get locked =>
      filtered.where((a) => !a.isCompleted).toList();

  int get totalUnlocked =>
      achievements.where((a) => a.isCompleted).length;

  Achievement? get lastUnlocked {
    final completed = achievements
        .where((a) => a.isCompleted && a.unlockedAt != null)
        .toList();
    if (completed.isEmpty) return null;
    completed.sort((a, b) => b.unlockedAt!.compareTo(a.unlockedAt!));
    return completed.first;
  }

  AchievementsState copyWith({
    List<Achievement>? achievements,
    AchievementStats? stats,
    bool? isLoading,
    String? error,
    AchievementDifficulty? activeFilter,
    bool clearFilter = false,
    bool clearError = false,
  }) {
    return AchievementsState(
      achievements: achievements ?? this.achievements,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
    );
  }
}

class AchievementsNotifier extends AsyncNotifier<AchievementsState> {
  late final AchievementsRepository _repository;

  @override
  Future<AchievementsState> build() async {
    _repository = AchievementsRepository();
    return _load();
  }

  Future<AchievementsState> _load() async {
    try {
      final results = await Future.wait([
        _repository.fetchAchievements(),
        _repository.fetchStats(),
      ]);
      return AchievementsState(
        achievements: results[0] as List<Achievement>,
        stats: results[1] as AchievementStats,
        isLoading: false,
      );
    } catch (e) {
      return AchievementsState(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _repository.recalculate();
    state = AsyncValue.data(await _load());
  }

  void setFilter(AchievementDifficulty? filter) {
    final current = state.value;
    if (current == null) return;
    if (filter == null) {
      state = AsyncValue.data(current.copyWith(clearFilter: true));
    } else {
      state = AsyncValue.data(current.copyWith(activeFilter: filter));
    }
  }
}

final achievementsProvider =
    AsyncNotifierProvider<AchievementsNotifier, AchievementsState>(
  AchievementsNotifier.new,
);
