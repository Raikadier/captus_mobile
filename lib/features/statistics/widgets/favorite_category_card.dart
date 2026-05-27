import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class FavoriteCategoryCard extends StatelessWidget {
  final String categoryName;
  const FavoriteCategoryCard({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary.withAlpha(25), AppColors.primary.withAlpha(10)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.primary.withAlpha(38), shape: BoxShape.circle),
            child: const Icon(Icons.favorite_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Categoría Favorita', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(categoryName, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text('donde más completas tareas', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.star_rounded, color: AppColors.warning, size: 28),
        ],
      ),
    );
  }
}
