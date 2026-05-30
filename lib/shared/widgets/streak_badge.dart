import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_radius.dart';

enum StreakSize { micro, mini, hero }

class StreakBadge extends StatelessWidget {
  final int days;
  final StreakSize size;

  const StreakBadge({super.key, required this.days, this.size = StreakSize.mini});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    switch (size) {
      case StreakSize.micro:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 12)),
            const SizedBox(width: AppSpacing.s1),
            Text(
              '$days',
              style: tt.labelLarge!.copyWith(color: AppColors.warning),
            ),
          ],
        );

      case StreakSize.mini:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.warning.withAlpha(AppAlpha.a10),
            borderRadius: BorderRadius.circular(AppRadius.r8),
            border: Border.all(color: AppColors.warning.withAlpha(AppAlpha.a30)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: AppSpacing.s1),
              Text(
                '$days días',
                style: tt.labelLarge!.copyWith(color: AppColors.warning),
              ),
            ],
          ),
        );

      case StreakSize.hero:
        return Container(
          padding: const EdgeInsets.all(AppSpacing.s6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warning.withAlpha(AppAlpha.a15),
                AppColors.primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.r8),
            border: Border.all(color: AppColors.warning.withAlpha(AppAlpha.a30)),
          ),
          child: Column(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 48)),
              const SizedBox(height: AppSpacing.s2),
              Text(
                '$days',
                style: tt.displaySmall!.copyWith(color: AppColors.warning),
              ),
              Text(
                'días consecutivos',
                style: tt.bodyMedium!.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        );
    }
  }
}
