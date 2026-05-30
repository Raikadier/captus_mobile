import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/user_statistics_provider.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';

class WeeklyBarChartCard extends StatelessWidget {
  final UserStatisticsState stats;
  const WeeklyBarChartCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final daily = stats.weeklyDailyCompletions;
    final maxY = daily.fold(0, (a, b) => a > b ? a : b).toDouble();
    final today = DateTime.now().weekday - 1;
    final activeDays = stats.activeDaysThisWeek;
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r7),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Esta Semana', style: tt.bodyMedium!.copyWith(color: AppColors.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.info.withAlpha(AppAlpha.a10), borderRadius: BorderRadius.circular(AppRadius.r3)),
                child: Text('$activeDays/7 días activos', style: tt.labelLarge!.copyWith(color: AppColors.info)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s1),
          Text('${stats.tasksCompletedThisWeek} tareas completadas esta semana', style: tt.labelLarge!.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.s5),
          SizedBox(
            height: 140,
            child: maxY == 0
                ? Center(child: Text('Completa tareas para ver el progreso semanal', style: tt.bodySmall!.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center))
                : BarChart(BarChartData(
                    maxY: maxY + 1,
                    minY: 0,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 0.5),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          interval: maxY > 0 ? (maxY / 4).ceilToDouble() : 1,
                          getTitlesWidget: (val, _) => Text(val.toInt().toString(), style: tt.labelSmall),
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, _) {
                            final idx = val.toInt();
                            final isToday = idx == today;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(labels[idx], style: tt.labelMedium!.copyWith(color: isToday ? AppColors.primary : AppColors.textSecondary)),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: List.generate(7, (i) {
                      final count = daily[i].toDouble();
                      final isToday = i == today;
                      final metGoal = daily[i] >= stats.dailyGoal;
                      final color = metGoal ? AppColors.primary : isToday ? AppColors.warning : AppColors.primary.withAlpha(AppAlpha.a30);
                      return BarChartGroupData(x: i, barRods: [
                        BarChartRodData(
                          toY: count == 0 ? 0.15 : count,
                          color: count == 0 ? AppColors.surface2 : color,
                          width: 22,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.r2)),
                        ),
                      ]);
                    }),
                  )),
          ),
          if (maxY > 0) ...[
            const SizedBox(height: AppSpacing.s3),
            Row(
              children: [
                _LegendDot(color: AppColors.primary, label: 'Meta cumplida'),
                const SizedBox(width: AppSpacing.s4),
                _LegendDot(color: AppColors.warning, label: 'Hoy (en progreso)'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: AppSpacing.s1),
        Text(label, style: tt.labelMedium!.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
