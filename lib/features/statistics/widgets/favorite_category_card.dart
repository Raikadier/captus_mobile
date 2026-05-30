import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

class FavoriteCategoryCard extends StatelessWidget {
  final String categoryName;
  const FavoriteCategoryCard({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary.withAlpha(25), AppColors.primary.withAlpha(10)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s3),
            decoration: BoxDecoration(color: AppColors.primary.withAlpha(38), shape: BoxShape.circle),
            child: const Icon(Icons.favorite_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: AppSpacing.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Categoría Favorita', style: tt.labelMedium),
                const SizedBox(height: AppSpacing.s1),
                Text(categoryName, style: tt.headlineSmall!.copyWith(color: AppColors.textPrimary)),
                Text('donde más completas tareas', style: tt.labelMedium!.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.star_rounded, color: AppColors.warning, size: 28),
        ],
      ),
    );
  }
}
