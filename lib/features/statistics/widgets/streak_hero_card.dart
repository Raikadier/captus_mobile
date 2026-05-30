import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/count_up_text.dart';
import '../providers/user_statistics_provider.dart';
import '../utils/streak_messages.dart';
import '../../../core/constants/app_spacing.dart';

class StreakHeroCard extends StatelessWidget {
  final UserStatisticsState stats;
  const StreakHeroCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final emoji = getStreakEmoji(stats.currentStreak);
    final title = getStreakTitle(stats.currentStreak);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: stats.hasStreak
              ? [AppColors.warning.withAlpha(40), AppColors.primaryDark]
              : [AppColors.surface, AppColors.surface2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: stats.hasStreak
              ? AppColors.warning.withAlpha(127)
              : AppColors.border,
          width: 1.5,
        ),
        boxShadow: stats.hasStreak
            ? [BoxShadow(color: AppColors.warning.withAlpha(40), blurRadius: 16, offset: const Offset(0, 4))]
            : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(width: AppSpacing.s4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CountUpText(
                    value: stats.currentStreak,
                    style: tt.displaySmall!.copyWith(color: stats.hasStreak ? AppColors.warning : AppColors.textPrimary),
                  ),
                  Text('días consecutivos', style: tt.bodyMedium!.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: stats.hasStreak ? AppColors.warning.withAlpha(30) : AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: stats.hasStreak ? AppColors.warning.withAlpha(80) : AppColors.primary.withAlpha(60)),
            ),
            child: Text(
              '🏅 Rango: $title',
              style: tt.labelLarge!.copyWith(color: stats.hasStreak ? AppColors.warning : AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface.withAlpha(200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              stats.streakMessage,
              textAlign: TextAlign.center,
              style: tt.bodySmall!.copyWith(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.s3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.warning, size: 16),
              const SizedBox(width: AppSpacing.s1),
              Text(
                'Mejor racha: ${stats.bestStreak} días',
                style: tt.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
