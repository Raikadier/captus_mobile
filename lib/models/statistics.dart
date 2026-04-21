class StatisticsModel {
  final int? idStatistics;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? lastRachaDate;
  final int racha;
  final int totalTasks;
  final int completedTasks;
  final int dailyGoal;
  final int bestStreak;
  final int? favoriteCategory;
  final String idUser;

  const StatisticsModel({
    this.idStatistics,
    required this.startDate,
    this.endDate,
    this.lastRachaDate,
    this.racha = 0,
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.dailyGoal = 5,
    this.bestStreak = 0,
    this.favoriteCategory,
    required this.idUser,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      idStatistics: json['id_Statistics'] as int?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'].toString())
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      lastRachaDate: json['lastRachaDate'] != null
          ? DateTime.tryParse(json['lastRachaDate'].toString())
          : null,
      racha: json['racha'] as int? ?? 0,
      totalTasks: json['totalTasks'] as int? ?? 0,
      completedTasks: json['completedTasks'] as int? ?? 0,
      dailyGoal: json['dailyGoal'] as int? ?? 5,
      bestStreak: json['bestStreak'] as int? ?? 0,
      favoriteCategory: json['favoriteCategory'] as int?,
      idUser: json['id_User']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idStatistics != null) 'id_Statistics': idStatistics,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'lastRachaDate': lastRachaDate?.toIso8601String(),
      'racha': racha,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'dailyGoal': dailyGoal,
      'bestStreak': bestStreak,
      'favoriteCategory': favoriteCategory,
      'id_User': idUser,
    };
  }

  StatisticsModel copyWith({
    int? idStatistics,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastRachaDate,
    int? racha,
    int? totalTasks,
    int? completedTasks,
    int? dailyGoal,
    int? bestStreak,
    int? favoriteCategory,
    String? idUser,
  }) {
    return StatisticsModel(
      idStatistics: idStatistics ?? this.idStatistics,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lastRachaDate: lastRachaDate ?? this.lastRachaDate,
      racha: racha ?? this.racha,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      bestStreak: bestStreak ?? this.bestStreak,
      favoriteCategory: favoriteCategory ?? this.favoriteCategory,
      idUser: idUser ?? this.idUser,
    );
  }

  static StatisticsModel createNew(String userId) {
    return StatisticsModel(
      startDate: DateTime.now(),
      racha: 0,
      totalTasks: 0,
      completedTasks: 0,
      dailyGoal: 5,
      bestStreak: 0,
      idUser: userId,
    );
  }
}
