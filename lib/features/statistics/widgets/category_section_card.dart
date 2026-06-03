import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/user_statistics_provider.dart';

class CategorySectionCard extends StatelessWidget {
  final UserStatisticsState stats;
  const CategorySectionCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.categoryTaskCounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border, width: 0.5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tareas por Categoría', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            Center(child: Text('Completa tareas para ver estadísticas por categoría', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary), textAlign: TextAlign.center)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tareas por Categoría', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: stats.categoryTaskCounts.take(5).toList().asMap().entries.map((e) {
                      final cat = e.value;
                      final color = AppColors.courseColors[cat.categoryId % AppColors.courseColors.length];
                      return PieChartSectionData(
                        color: color, value: cat.completedCount.toDouble(),
                        title: '${cat.completedCount}', radius: 50,
                        titleStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textOnPrimary),
                      );
                    }).toList(),
                  )),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: stats.categoryTaskCounts.take(5).map((cat) {
                    final color = AppColors.courseColors[cat.categoryId % AppColors.courseColors.length];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(
                            cat.categoryName.length > 14 ? '${cat.categoryName.substring(0, 12)}…' : cat.categoryName,
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...stats.categoryTaskCounts.take(5).map((cat) {
            final maxCount = stats.categoryTaskCounts.first.completedCount;
            final progress = maxCount > 0 ? cat.completedCount / maxCount : 0.0;
            final color = AppColors.courseColors[cat.categoryId % AppColors.courseColors.length];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(cat.categoryName, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
                      Text('${cat.completedCount} completadas', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress, minHeight: 7,
                      backgroundColor: color.withAlpha(38),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
