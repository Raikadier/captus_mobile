import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/count_up_text.dart';
import '../providers/user_statistics_provider.dart';

class QuickStatsRow extends StatelessWidget {
  final UserStatisticsState stats;
  const QuickStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: StatCard(icon: Icons.check_circle_rounded, iconColor: AppColors.primary, label: 'Completadas', value: stats.completedTasks, subtitle: 'en total')),
        const SizedBox(width: 10),
        Expanded(child: StatCard(icon: Icons.assignment_rounded, iconColor: AppColors.info, label: 'Totales', value: stats.totalTasks, subtitle: 'creadas')),
        const SizedBox(width: 10),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          CountUpText(
            value: value,
            suffix: valueSuffix,
            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
