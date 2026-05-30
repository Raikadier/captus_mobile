import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/cactus_refresh.dart';
import '../providers/user_statistics_provider.dart';
import '../widgets/streak_hero_card.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/quick_stats_row.dart';
import '../widgets/favorite_category_card.dart';
import '../widgets/weekly_bar_chart_card.dart';
import '../widgets/category_section_card.dart';
import '../widgets/activity_summary_section.dart';
import '../widgets/achievements_card.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../shared/widgets/captus_pressable.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userStatisticsProvider.notifier).checkAndResetStreakIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(userStatisticsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Mis Estadísticas'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => _showGoalSettings(context)),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildError(e.toString()),
        data: (stats) => CactusRefresh(
          onRefresh: () async => ref.invalidate(userStatisticsProvider),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.s4),
            children: [
              StreakHeroCard(stats: stats),
              const SizedBox(height: AppSpacing.s5),
              DailyGoalCard(stats: stats),
              const SizedBox(height: AppSpacing.s5),
              QuickStatsRow(stats: stats),
              const SizedBox(height: AppSpacing.s5),
              if (stats.favoriteCategoryName != null) ...[
                FavoriteCategoryCard(categoryName: stats.favoriteCategoryName!),
                const SizedBox(height: AppSpacing.s5),
              ],
              WeeklyBarChartCard(stats: stats),
              const SizedBox(height: AppSpacing.s5),
              CategorySectionCard(stats: stats),
              const SizedBox(height: AppSpacing.s5),
              ActivitySummarySection(stats: stats),
              const SizedBox(height: AppSpacing.s5),
              const AchievementsCard(),
              const SizedBox(height: AppSpacing.s8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: AppSpacing.s3),
          Text('Error al cargar estadísticas', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.s3),
          TextButton(onPressed: () => ref.invalidate(userStatisticsProvider), child: const Text('Reintentar')),
        ],
      ),
    );
  }

  void _showGoalSettings(BuildContext context) {
    final stats = ref.read(userStatisticsProvider).value;
    if (stats == null) return;

    int selectedGoal = stats.dailyGoal;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.r8))),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(AppSpacing.s6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Meta Diaria', style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.s2),
              Text('Establece cuántas tareas quieres completar cada día para mantener tu racha.',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.s6),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: [3, 5, 7, 10, 15, 20].map((goal) {
                  final isSelected = selectedGoal == goal;
                  return CaptusPressable(
                    onTap: () => setState(() => selectedGoal = goal),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface2,
                        borderRadius: BorderRadius.circular(AppRadius.r5),
                        border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
                      ),
                      child: Text('$goal', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.s6),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(userStatisticsProvider.notifier).setDailyGoal(selectedGoal);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.r5)),
                  ),
                  child: Text('Guardar', style: Theme.of(context).textTheme.titleMedium),
                ),
              ),
              const SizedBox(height: AppSpacing.s4),
            ],
          ),
        ),
      ),
    );
  }
}
