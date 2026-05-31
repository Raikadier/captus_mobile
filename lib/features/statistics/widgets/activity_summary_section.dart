import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/user_statistics_provider.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';

class ActivitySummarySection extends StatelessWidget {
  final UserStatisticsState stats;
  const ActivitySummarySection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RESUMEN DE ACTIVIDAD',
            style: tt.labelMedium),
        const SizedBox(height: AppSpacing.s2 + 2),
        Row(
          children: [
            Expanded(child: _ActivityCard(
              icon: Icons.note_rounded, iconColor: AppColors.primary,
              title: 'Notas', main: '${stats.totalNotes}', mainLabel: 'total',
              sub: '${stats.notesCreatedThisWeek} esta semana',
            )),
            const SizedBox(width: AppSpacing.s2 + 2),
            Expanded(child: _ActivityCard(
              icon: Icons.calendar_today_rounded, iconColor: AppColors.info,
              title: 'Eventos', main: '${stats.totalEvents}', mainLabel: 'total',
              sub: '${stats.eventsThisWeek} esta semana',
            )),
          ],
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String main;
  final String mainLabel;
  final String sub;

  const _ActivityCard({
    required this.icon, required this.iconColor, required this.title,
    required this.main, required this.mainLabel, required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s3 + 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r6),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s2),
                decoration: BoxDecoration(color: iconColor.withAlpha(AppAlpha.a10), borderRadius: BorderRadius.circular(AppRadius.r3)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.s2),
              Text(title, style: tt.bodySmall!.copyWith(color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: AppSpacing.s3),
          RichText(
            text: TextSpan(children: [
              TextSpan(text: main, style: tt.displaySmall!.copyWith(color: AppColors.textPrimary)),
              TextSpan(text: ' $mainLabel', style: tt.labelLarge!.copyWith(color: AppColors.textSecondary)),
            ]),
          ),
          const SizedBox(height: AppSpacing.s1),
          Text(sub, style: tt.labelMedium!.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
