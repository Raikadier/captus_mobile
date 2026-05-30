import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/achievements_provider.dart';
import '../../../models/achievement.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_radius.dart';
import '../../../shared/widgets/captus_pressable.dart';

class AchievementsCard extends ConsumerWidget {
  const AchievementsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final achievementsAsync = ref.watch(achievementsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Logros', style: tt.headlineSmall!.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: AppSpacing.s3),
        achievementsAsync.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.s4), child: CircularProgressIndicator())),
          error: (_, __) => const SizedBox.shrink(),
          data: (state) {
            final unlocked = state.totalUnlocked;
            final progress = unlocked / kTotalAchievements;
            final last = state.lastUnlocked;
            final recentlyUnlocked = state.achievements.where((a) => a.isCompleted).take(3).toList();

            return Container(
              padding: const EdgeInsets.all(AppSpacing.s4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r7),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🏅', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: AppSpacing.s3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$unlocked / $kTotalAchievements desbloqueados',
                                style: tt.bodyMedium!.copyWith(color: AppColors.textPrimary)),
                            const SizedBox(height: AppSpacing.s1),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.r1),
                              child: LinearProgressIndicator(
                                value: progress, minHeight: 7,
                                backgroundColor: AppColors.border,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s1),
                            Text('${(progress * 100).toStringAsFixed(0)}% completado',
                                style: tt.labelMedium!.copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (last != null) ...[
                    const SizedBox(height: AppSpacing.s3),
                    const Divider(height: 0, color: AppColors.border),
                    const SizedBox(height: AppSpacing.s3),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: AppSpacing.s1),
                        Expanded(
                          child: Text('Último logro: ${last.definition.name}',
                              style: tt.labelLarge!.copyWith(color: AppColors.textPrimary)),
                        ),
                        if (last.unlockedAt != null)
                          Text(_fmtDate(last.unlockedAt!), style: tt.labelMedium!.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                  if (recentlyUnlocked.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.s3),
                    Wrap(
                      spacing: 8, runSpacing: 6,
                      children: recentlyUnlocked.map((a) {
                        final c = a.definition.difficulty.color;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: c.withAlpha(AppAlpha.a10), borderRadius: BorderRadius.circular(AppRadius.r8), border: Border.all(color: c.withAlpha(AppAlpha.a30))),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(a.definition.icon, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: AppSpacing.s1),
                              Text(a.definition.name, style: tt.labelMedium),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.s3),
                  CaptusPressable(
                    onTap: () => context.push('/statistics/achievements'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Ver todos los logros', style: tt.bodySmall!.copyWith(color: AppColors.primary)),
                        const SizedBox(width: AppSpacing.s1),
                        const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}
