import 'package:flutter/material.dart';

// Total de logros en el catálogo
const int kTotalAchievements = 18;

enum AchievementDifficulty { easy, medium, hard, special, epic }

extension AchievementDifficultyExtension on AchievementDifficulty {
  String get label {
    switch (this) {
      case AchievementDifficulty.easy:
        return 'Fácil';
      case AchievementDifficulty.medium:
        return 'Medio';
      case AchievementDifficulty.hard:
        return 'Difícil';
      case AchievementDifficulty.special:
        return 'Especial';
      case AchievementDifficulty.epic:
        return 'Épico';
    }
  }

  Color get color {
    switch (this) {
      case AchievementDifficulty.easy:
        return const Color(0xFF4CAF50);
      case AchievementDifficulty.medium:
        return const Color(0xFFFF9800);
      case AchievementDifficulty.hard:
        return const Color(0xFFF44336);
      case AchievementDifficulty.special:
        return const Color(0xFF9C27B0);
      case AchievementDifficulty.epic:
        return const Color(0xFF673AB7);
    }
  }
}

class AchievementDefinition {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String type;
  final AchievementDifficulty difficulty;
  final int targetValue;

  const AchievementDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.type,
    required this.difficulty,
    required this.targetValue,
  });
}

// Catálogo estático — espejo exacto de achievementsConfig.js
const Map<String, AchievementDefinition> kAchievements = {
  // FÁCIL
  'first_task': AchievementDefinition(
    id: 'first_task',
    name: 'Primer Paso',
    description: 'Completaste tu primera tarea',
    icon: '🎯',
    difficulty: AchievementDifficulty.easy,
    targetValue: 1,
    type: 'completed_tasks',
  ),
  'prioritario': AchievementDefinition(
    id: 'prioritario',
    name: 'Prioritario',
    description: 'Creaste tu primera tarea de prioridad alta',
    icon: '⭐',
    difficulty: AchievementDifficulty.easy,
    targetValue: 1,
    type: 'high_priority_tasks',
  ),
  'subdivisor': AchievementDefinition(
    id: 'subdivisor',
    name: 'Subdivisor',
    description: 'Creaste tu primera subtarea',
    icon: '📝',
    difficulty: AchievementDifficulty.easy,
    targetValue: 1,
    type: 'subtasks_created',
  ),
  'explorador': AchievementDefinition(
    id: 'explorador',
    name: 'Explorador',
    description: 'Creaste 5 tareas diferentes',
    icon: '🗺️',
    difficulty: AchievementDifficulty.easy,
    targetValue: 5,
    type: 'tasks_created',
  ),

  // MEDIO
  'productivo': AchievementDefinition(
    id: 'productivo',
    name: 'Productivo',
    description: 'Completaste 25 tareas totales',
    icon: '⚡',
    difficulty: AchievementDifficulty.medium,
    targetValue: 25,
    type: 'completed_tasks',
  ),
  'consistente': AchievementDefinition(
    id: 'consistente',
    name: 'Consistente',
    description: 'Mantuviste una racha de 3 días',
    icon: '🔥',
    difficulty: AchievementDifficulty.medium,
    targetValue: 3,
    type: 'streak',
  ),
  'tempranero': AchievementDefinition(
    id: 'tempranero',
    name: 'Tempranero',
    description: 'Completaste 3 tareas antes de las 9 AM',
    icon: '🌅',
    difficulty: AchievementDifficulty.medium,
    targetValue: 3,
    type: 'early_tasks',
  ),
  'multitarea': AchievementDefinition(
    id: 'multitarea',
    name: 'Multitarea',
    description: 'Completaste 5 subtareas en una tarea padre',
    icon: '🎪',
    difficulty: AchievementDifficulty.medium,
    targetValue: 5,
    type: 'subtasks_completed',
  ),

  // DIFÍCIL
  'maraton': AchievementDefinition(
    id: 'maraton',
    name: 'Maratón',
    description: 'Completaste 100 tareas totales',
    icon: '🏃',
    difficulty: AchievementDifficulty.hard,
    targetValue: 100,
    type: 'completed_tasks',
  ),
  'leyenda': AchievementDefinition(
    id: 'leyenda',
    name: 'Leyenda',
    description: 'Mantuviste una racha de 30 días',
    icon: '👑',
    difficulty: AchievementDifficulty.hard,
    targetValue: 30,
    type: 'streak',
  ),
  'velocista': AchievementDefinition(
    id: 'velocista',
    name: 'Velocista',
    description: 'Completaste 10 tareas en un día',
    icon: '💨',
    difficulty: AchievementDifficulty.hard,
    targetValue: 10,
    type: 'tasks_in_day',
  ),
  'perfeccionista': AchievementDefinition(
    id: 'perfeccionista',
    name: 'Perfeccionista',
    description: 'Completaste 50 tareas sin subtareas',
    icon: '🎯',
    difficulty: AchievementDifficulty.hard,
    targetValue: 50,
    type: 'solo_tasks',
  ),

  // ESPECIAL
  'dominguero': AchievementDefinition(
    id: 'dominguero',
    name: 'Dominguero',
    description: 'Completaste 5 tareas en domingo',
    icon: '⛱️',
    difficulty: AchievementDifficulty.special,
    targetValue: 5,
    type: 'sunday_tasks',
  ),
  'maestro': AchievementDefinition(
    id: 'maestro',
    name: 'Maestro',
    description: 'Completaste 500 tareas totales',
    icon: '🎓',
    difficulty: AchievementDifficulty.special,
    targetValue: 500,
    type: 'completed_tasks',
  ),

  // ÉPICO
  'inmortal': AchievementDefinition(
    id: 'inmortal',
    name: 'Inmortal',
    description: 'Mantuviste una racha de 100 días',
    icon: '⚡',
    difficulty: AchievementDifficulty.epic,
    targetValue: 100,
    type: 'streak',
  ),
  'titan': AchievementDefinition(
    id: 'titan',
    name: 'Titán',
    description: 'Completaste 1000 tareas totales',
    icon: '🏔️',
    difficulty: AchievementDifficulty.epic,
    targetValue: 1000,
    type: 'completed_tasks',
  ),
  'dios_productividad': AchievementDefinition(
    id: 'dios_productividad',
    name: 'Dios de la Productividad',
    description: 'Completaste 5000 tareas totales',
    icon: '👑',
    difficulty: AchievementDifficulty.epic,
    targetValue: 5000,
    type: 'completed_tasks',
  ),
};

class UserAchievementData {
  final int id;
  final String idUser;
  final String achievementId;
  final int progress;
  final bool isCompleted;
  final DateTime? unlockedAt;

  const UserAchievementData({
    required this.id,
    required this.idUser,
    required this.achievementId,
    required this.progress,
    required this.isCompleted,
    this.unlockedAt,
  });

  factory UserAchievementData.fromJson(Map<String, dynamic> json) {
    return UserAchievementData(
      id: json['id'] as int,
      idUser: json['id_User'] as String,
      achievementId: json['achievementId'] as String,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.tryParse(json['unlockedAt'] as String)
          : null,
    );
  }
}

class Achievement {
  final AchievementDefinition definition;
  final UserAchievementData? data;

  const Achievement({required this.definition, this.data});

  bool get isCompleted => data?.isCompleted ?? false;
  int get progress => data?.progress ?? 0;
  double get progressPercent =>
      (progress / definition.targetValue).clamp(0.0, 1.0);
  DateTime? get unlockedAt => data?.unlockedAt;
  String get id => definition.id;
}

class AchievementStats {
  final int totalAchievements;
  final int completedAchievements;
  final double completionRate;

  const AchievementStats({
    required this.totalAchievements,
    required this.completedAchievements,
    required this.completionRate,
  });

  factory AchievementStats.fromJson(Map<String, dynamic> json) {
    return AchievementStats(
      totalAchievements: (json['totalAchievements'] as num?)?.toInt() ?? 0,
      completedAchievements:
          (json['completedAchievements'] as num?)?.toInt() ?? 0,
      completionRate:
          ((json['completionRate'] as num?)?.toDouble() ?? 0.0) / 100.0,
    );
  }
}
