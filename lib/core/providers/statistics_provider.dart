import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';

class SubjectStat {
  final String name;
  final double progress;
  final int colorIndex;
  const SubjectStat({
    required this.name,
    required this.progress,
    required this.colorIndex,
  });
}

class AppStatistics {
  final int completedTasks;
  final int totalTasks;
  final int currentStreak;
  final int bestStreak;
  final int activeCourses;
  final List<SubjectStat> subjects;
  // 7 values Mon–Sun representing completed tasks per day
  final List<int> weeklyActivity;

  const AppStatistics({
    this.completedTasks = 0,
    this.totalTasks = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.activeCourses = 0,
    this.subjects = const [],
    this.weeklyActivity = const [0, 0, 0, 0, 0, 0, 0],
  });
}

Future<AppStatistics> _fetchStatistics() async {
  // Run the three calls in parallel; degrade gracefully if any fails
  final results = await Future.wait([
    ApiClient.instance
        .get<Map<String, dynamic>>('/statistics')
        .then((r) => r.data)
        .catchError((_) => null),
    ApiClient.instance
        .get<Map<String, dynamic>>('/statistics/streak-stats')
        .then((r) => r.data)
        .catchError((_) => null),
    ApiClient.instance
        .get<Map<String, dynamic>>('/statistics/tasks')
        .then((r) => r.data)
        .catchError((_) => null),
  ]);

  final main = _unwrap(results[0]);
  final streak = _unwrap(results[1]);
  final tasks = _unwrap(results[2]);

  // Parse subjects
  final rawSubjects = main['subjects'] as List? ?? [];
  final subjects = rawSubjects.asMap().entries.map((e) {
    final s = e.value as Map<String, dynamic>;
    final progress = (s['progress'] as num?)?.toDouble() ??
        ((s['grade'] as num?)?.toDouble() ?? 0) / 100;
    return SubjectStat(
      name: s['name']?.toString() ?? '',
      progress: progress.clamp(0.0, 1.0),
      colorIndex: e.key % 6,
    );
  }).toList();

  // Parse weekly activity from productivityChart
  final rawChart = tasks['productivityChart'] as List? ?? [];
  final weeklyActivity = List.generate(7, (i) {
    if (i < rawChart.length) {
      final day = rawChart[i] as Map<String, dynamic>;
      return (day['completed'] as num?)?.toInt() ?? 0;
    }
    return 0;
  });

  return AppStatistics(
    completedTasks: (main['completedTasks'] as num?)?.toInt() ?? 0,
    totalTasks: (main['totalTasks'] as num?)?.toInt() ?? 0,
    currentStreak: (streak['currentStreak'] as num?)?.toInt() ??
        (main['racha'] as num?)?.toInt() ?? 0,
    bestStreak: (streak['bestStreak'] as num?)?.toInt() ?? 0,
    activeCourses: subjects.length,
    subjects: subjects,
    weeklyActivity: weeklyActivity,
  );
}

Map<String, dynamic> _unwrap(dynamic raw) {
  if (raw == null) return {};
  if (raw is Map<String, dynamic>) {
    return (raw['data'] as Map<String, dynamic>?) ?? raw;
  }
  return {};
}

final statisticsProvider = FutureProvider.autoDispose<AppStatistics>(
  (_) => _fetchStatistics(),
);
