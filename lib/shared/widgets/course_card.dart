import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_gradients.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_radius.dart';
import '../../models/course.dart';
import 'captus_pressable.dart';

/// Premium course card — Captus Design System v2.
///
/// Upgrades vs v1:
///   - Gradient color bar (8px, course color → darker tint)
///   - AppShadows.sm elevation for depth
///   - CaptusPressable for scale + opacity press feedback
///   - Refined badge design for pending activities (pill, stronger contrast)
///   - Progress bar uses 6px height matching design system spec
///   - AppSpacing tokens throughout
class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback? onTap;

  const CourseCard({super.key, required this.course, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final gradient = AppGradients.courseGradient(course.colorIndex);
    final color = AppColors.courseColor(course.colorIndex);
    final trimmedName = course.name.trim();
    final displayName = trimmedName.isEmpty ? 'Sin nombre' : trimmedName;
    final displayInitial = trimmedName.isEmpty ? '?' : trimmedName[0].toUpperCase();

    return CaptusPressable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r7),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gradient color bar ──────────────────────────────────────────
            Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
            ),

            // ── Card body ───────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPaddingCompact),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon + pending badge row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subject avatar
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color.withAlpha(AppAlpha.a15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              displayInitial,
                              style: tt.headlineMedium,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Pending activities badge
                        if (course.pendingActivities > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s2,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              '${course.pendingActivities}',
                              style: tt.labelMedium!.copyWith(color: AppColors.error),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.s2),

                    // Course name
                    Text(
                      displayName,
                      style: tt.titleSmall!.copyWith(color: AppColors.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    // Course code
                    Text(
                      course.code,
                      style: tt.labelMedium!.copyWith(color: AppColors.textSecondary),
                    ),

                    const Spacer(),

                    // Progress bar (v2: 6px height, rounded)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: LinearProgressIndicator(
                        value: course.progress,
                        minHeight: 6,
                        backgroundColor: color.withAlpha(AppAlpha.a15),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.s1),

                    // Progress label
                    Text(
                      '${(course.progress * 100).toInt()}% completado',
                      style: tt.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
