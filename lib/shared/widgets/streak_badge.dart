import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

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
            const SizedBox(width: 2),
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
            color: AppColors.warning.withAlpha(25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.warning.withAlpha(76)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                '$days días',
                style: tt.labelLarge!.copyWith(color: AppColors.warning),
              ),
            ],
          ),
        );

      case StreakSize.hero:
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warning.withAlpha(38),
                AppColors.primaryDark,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.warning.withAlpha(76)),
          ),
          child: Column(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 8),
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
