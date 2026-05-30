import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/count_up_text.dart';
import '../providers/user_statistics_provider.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';

class QuickStatsRow extends StatelessWidget {
  final UserStatisticsState stats;
  const QuickStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(child: StatCard(icon: Icons.check_circle_rounded, iconColor: AppColors.primary, label: 'Completadas', value: stats.completedTasks, subtitle: 'en total')),
        const SizedBox(width: AppSpacing.s2 + 2),
        Expanded(child: StatCard(icon: Icons.assignment_rounded, iconColor: AppColors.info, label: 'Totales', value: stats.totalTasks, subtitle: 'creadas')),
        const SizedBox(width: AppSpacing.s2 + 2),
        Expanded(child: StatCard(icon: Icons.percent_rounded, iconColor: AppColors.primary, label: 'Éxito', value: (stats.completionPercentage * 100).toInt(), subtitle: 'completado', valueSuffix: '%')),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final num value;
  final String subtitle;
  final String valueSuffix;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtitle,
    this.valueSuffix = '',
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r5),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: AppSpacing.s2),
          CountUpText(
            value: value,
            suffix: valueSuffix,
            style: tt.displaySmall!.copyWith(color: AppColors.textPrimary),
          ),
          Text(label, style: tt.labelSmall),
          Text(subtitle, style: tt.labelSmall),
        ],
      ),
    );
  }
}
