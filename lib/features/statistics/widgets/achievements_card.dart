import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/achievements_provider.dart';
import '../../../models/achievement.dart';

class AchievementsCard extends ConsumerWidget {
  const AchievementsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Logros', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        achievementsAsync.when(
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
          error: (_, __) => const SizedBox.shrink(),
          data: (state) {
            final unlocked = state.totalUnlocked;
            final progress = unlocked / kTotalAchievements;
            final last = state.lastUnlocked;
            final recentlyUnlocked = state.achievements.where((a) => a.isCompleted).take(3).toList();

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🏅', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$unlocked / $kTotalAchievements desbloqueados',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress, minHeight: 7,
                                backgroundColor: AppColors.border,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('${(progress * 100).toStringAsFixed(0)}% completado',
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (last != null) ...[
                    const SizedBox(height: 14),
                    const Divider(height: 0, color: AppColors.border),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('Último logro: ${last.definition.name}',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        ),
                        if (last.unlockedAt != null)
                          Text(_fmtDate(last.unlockedAt!), style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                  if (recentlyUnlocked.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8, runSpacing: 6,
                      children: recentlyUnlocked.map((a) {
                        final c = a.definition.difficulty.color;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: c.withAlpha(25), borderRadius: BorderRadius.circular(20), border: Border.all(color: c.withAlpha(80))),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(a.definition.icon, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text(a.definition.name, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: c)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => context.push('/statistics/achievements'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Ver todos los logros', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        const SizedBox(width: 4),
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
