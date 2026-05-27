import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/count_up_text.dart';
import '../providers/user_statistics_provider.dart';
import '../utils/streak_messages.dart';

class StreakHeroCard extends StatelessWidget {
  final UserStatisticsState stats;
  const StreakHeroCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CountUpText(
                    value: stats.currentStreak,
                    style: GoogleFonts.inter(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: stats.hasStreak ? AppColors.warning : AppColors.textPrimary,
                      height: 1,
                    ),
                  ),
                  Text('días consecutivos', style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: stats.hasStreak ? AppColors.warning.withAlpha(30) : AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: stats.hasStreak ? AppColors.warning.withAlpha(80) : AppColors.primary.withAlpha(60)),
            ),
            child: Text(
              '🏅 Rango: $title',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: stats.hasStreak ? AppColors.warning : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
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
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary, fontStyle: FontStyle.italic, height: 1.5),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.warning, size: 16),
              const SizedBox(width: 4),
              Text(
                'Mejor racha: ${stats.bestStreak} días',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
