import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/statistics_provider.dart';
import '../../../shared/widgets/streak_badge.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  int _periodIndex = 0;
  final _periods = ['7D', '30D', 'Semestre'];

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi Progreso'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: _periods.asMap().entries.map((e) {
                final isSelected = _periodIndex == e.key;
                return GestureDetector(
                  onTap: () => setState(() => _periodIndex = e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      e.value,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.black : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildBody(const AppStatistics()),
        data: _buildBody,
      ),
    );
  }

  Widget _buildBody(AppStatistics stats) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        StreakBadge(days: stats.currentStreak, size: StreakSize.hero),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Mejor racha: ${stats.bestStreak} días',
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 24),

        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          children: [
            _MetricCard(
                label: 'Tareas completadas',
                value: '${stats.completedTasks}',
                trend: '=',
                trendPositive: true),
            _MetricCard(
                label: 'Total de tareas',
                value: '${stats.totalTasks}',
                trend: '=',
                trendPositive: true),
            _MetricCard(
                label: 'Racha actual',
                value: '${stats.currentStreak}d',
                trend: '=',
                trendPositive: true),
            _MetricCard(
                label: 'Materias activas',
                value: '${stats.activeCourses}',
                trend: '=',
                trendPositive: true),
          ],
        ),
        const SizedBox(height: 24),

        Text(
          'ACTIVIDAD SEMANAL',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        _WeekBarChart(values: stats.weeklyActivity),
        const SizedBox(height: 24),

        if (stats.subjects.isNotEmpty) ...[
          Text(
            'DISTRIBUCIÓN POR MATERIA',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _SubjectDistribution(subjects: stats.subjects),
          const SizedBox(height: 24),
        ],

        Text(
          'MAPA DE ACTIVIDAD',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        _HeatMap(),
        const SizedBox(height: 24),

        Row(
          children: [
            Text(
              'LOGROS RECIENTES',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/statistics/achievements'),
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, minimumSize: Size.zero),
              child: const Text('Ver todos', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: ['🏆', '🔥', '📚', '⚡']
              .map((e) => Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(25),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.warning.withAlpha(76)),
                    ),
                    child: Center(
                        child:
                            Text(e, style: const TextStyle(fontSize: 26))),
                  ))
              .toList(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final bool trendPositive;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.trendPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
            maxLines: 2,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (trend != '=')
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (trendPositive ? AppColors.primary : AppColors.error)
                        .withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trend,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color:
                          trendPositive ? AppColors.primary : AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekBarChart extends StatelessWidget {
  final List<int> values;
  static const _days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  const _WeekBarChart({required this.values});

  @override
  Widget build(BuildContext context) {
    final safeValues = List.generate(7, (i) => i < values.length ? values[i] : 0);
    final maxVal = safeValues.reduce((a, b) => a > b ? a : b).toDouble();
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_days.length, (i) {
          final pct = maxVal > 0 ? safeValues[i] / maxVal : 0.0;
          final isToday = i == DateTime.now().weekday - 1;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 60 * pct,
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppColors.primary
                          : AppColors.primary.withAlpha(76),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _days[i],
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color:
                          isToday ? AppColors.primary : AppColors.textSecondary,
                      fontWeight:
                          isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SubjectDistribution extends StatelessWidget {
  final List<SubjectStat> subjects;
  const _SubjectDistribution({required this.subjects});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: subjects.map((s) {
          final color = AppColors.courseColor(s.colorIndex);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(s.name,
                        style: GoogleFonts.inter(fontSize: 12))),
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    value: s.progress,
                    color: color,
                    backgroundColor: color.withAlpha(38),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(s.progress * 100).toInt()}%',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _HeatMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Wrap(
        spacing: 3,
        runSpacing: 3,
        children: List.generate(84, (i) {
          final intensity = [0, 0, 1, 2, 3, 1, 0][i % 7];
          return Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: intensity == 0
                  ? AppColors.surface2
                  : AppColors.primary.withAlpha((intensity * 85).toInt()),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
