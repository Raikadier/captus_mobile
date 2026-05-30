import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/user_statistics_provider.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';

class CategorySectionCard extends StatelessWidget {
  final UserStatisticsState stats;
  const CategorySectionCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    if (stats.categoryTaskCounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.s4),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.r7), border: Border.all(color: AppColors.border, width: 0.5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tareas por Categoría', style: tt.bodyMedium!.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.s4),
            Center(child: Text('Completa tareas para ver estadísticas por categoría', style: tt.bodySmall!.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.r7), border: Border.all(color: AppColors.border, width: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tareas por Categoría', style: tt.bodyMedium!.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: AppSpacing.s4),
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
                        titleStyle: tt.labelMedium!.copyWith(color: AppColors.textOnPrimary),
                      );
                    }).toList(),
                  )),
                ),
                const SizedBox(width: AppSpacing.s4),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: stats.categoryTaskCounts.take(5).map((cat) {
                    final color = AppColors.courseColors[cat.categoryId % AppColors.courseColors.length];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s1),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                          const SizedBox(width: AppSpacing.s1),
                          Text(
                            cat.categoryName.length > 14 ? '${cat.categoryName.substring(0, 12)}…' : cat.categoryName,
                            style: tt.labelMedium!.copyWith(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
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
                      Expanded(child: Text(cat.categoryName, style: tt.labelLarge!.copyWith(color: AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
                      Text('${cat.completedCount} completadas', style: tt.labelMedium),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s1),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.r1),
                    child: LinearProgressIndicator(
                      value: progress, minHeight: 7,
                      backgroundColor: color.withAlpha(AppAlpha.a15),
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
