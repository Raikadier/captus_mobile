import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/user_statistics_provider.dart';

class ActivitySummarySection extends StatelessWidget {
  final UserStatisticsState stats;
  const ActivitySummarySection({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RESUMEN DE ACTIVIDAD',
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.8)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _ActivityCard(
              icon: Icons.note_rounded, iconColor: AppColors.primary,
              title: 'Notas', main: '${stats.totalNotes}', mainLabel: 'total',
              sub: '${stats.notesCreatedThisWeek} esta semana',
            )),
            const SizedBox(width: 10),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconColor.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(children: [
              TextSpan(text: main, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              TextSpan(text: ' $mainLabel', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ),
          const SizedBox(height: 2),
          Text(sub, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
