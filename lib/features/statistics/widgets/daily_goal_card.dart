import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/user_statistics_provider.dart';

class DailyGoalCard extends StatelessWidget {
  final UserStatisticsState stats;
  const DailyGoalCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final progress = stats.dailyProgress;
    final isGoalMet = stats.dailyGoalMet;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGoalMet ? AppColors.primary.withAlpha(80) : AppColors.border,
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
                  const SizedBox(width: 8),
                  Text('Meta Diaria', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isGoalMet ? AppColors.primary.withAlpha(25) : AppColors.surface2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${stats.dailyCompletedTasks}/${stats.dailyGoal}',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: isGoalMet ? AppColors.primary : AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.surface2,
              valueColor: AlwaysStoppedAnimation<Color>(isGoalMet ? AppColors.primary : AppColors.warning),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isGoalMet ? '¡Meta alcanzada! 🎉' : '${stats.dailyGoal - stats.dailyCompletedTasks} tarea(s) para completar la meta',
                style: GoogleFonts.inter(fontSize: 12, color: isGoalMet ? AppColors.primary : AppColors.textSecondary),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: isGoalMet ? AppColors.primary : AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
