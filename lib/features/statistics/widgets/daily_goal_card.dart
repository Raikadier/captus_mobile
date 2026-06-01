import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/user_statistics_provider.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';

class DailyGoalCard extends StatelessWidget {
  final UserStatisticsState stats;
  const DailyGoalCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final progress = stats.dailyProgress;
    final isGoalMet = stats.dailyGoalMet;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r7),
        border: Border.all(
          color: isGoalMet ? AppColors.primary.withAlpha(AppAlpha.a30) : AppColors.border,
          width: isGoalMet ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isGoalMet ? Icons.check_circle_rounded : Icons.track_changes_rounded,
                    color: isGoalMet ? AppColors.primary : AppColors.warning,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.s2),
                  Text('Meta Diaria', style: tt.bodyMedium!.copyWith(color: AppColors.textPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s2 + 2, vertical: AppSpacing.s1),
                decoration: BoxDecoration(
                  color: isGoalMet ? AppColors.primary.withAlpha(AppAlpha.a10) : AppColors.surface2,
                  borderRadius: BorderRadius.circular(AppRadius.r3),
                ),
                child: Text(
                  '${stats.dailyCompletedTasks}/${stats.dailyGoal}',
                  style: tt.titleSmall!.copyWith(color: isGoalMet ? AppColors.primary : AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.r2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.surface2,
              valueColor: AlwaysStoppedAnimation<Color>(isGoalMet ? AppColors.primary : AppColors.warning),
            ),
          ),
          const SizedBox(height: AppSpacing.s2 + 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isGoalMet ? '¡Meta alcanzada! 🎉' : '${stats.dailyGoal - stats.dailyCompletedTasks} tarea(s) para completar la meta',
                style: tt.bodySmall!.copyWith(color: isGoalMet ? AppColors.primary : AppColors.textSecondary),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: tt.labelLarge!.copyWith(color: isGoalMet ? AppColors.primary : AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
