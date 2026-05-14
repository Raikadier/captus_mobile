import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';

// ─── Base ────────────────────────────────────────────────────────────────────

/// Generic shimmer box. Use as a building block for screen-specific skeletons.
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface2,
      highlightColor: AppColors.surface3,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// @deprecated Use [SkeletonBox] instead.
typedef LoadingShimmer = SkeletonBox;

// ─── Task skeletons ───────────────────────────────────────────────────────────

/// Skeleton for a single TaskCard row.
class TaskCardShimmer extends StatelessWidget {
  const TaskCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface2,
      highlightColor: AppColors.surface3,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        height: 76,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Priority bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 200, color: AppColors.surface2),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 120, color: AppColors.surface2),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Checkbox placeholder
            Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for a vertical list of [TaskCardShimmer].
class TaskListShimmer extends StatelessWidget {
  final int count;
  const TaskListShimmer({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (_) => const TaskCardShimmer()),
    );
  }
}

// ─── Course skeletons ─────────────────────────────────────────────────────────

/// Skeleton for a single CourseCard in the grid.
class CourseCardShimmer extends StatelessWidget {
  const CourseCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface2,
      highlightColor: AppColors.surface3,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color bar
            Container(
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon placeholder
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Title lines
                    Container(height: 13, color: AppColors.surface2),
                    const SizedBox(height: 6),
                    Container(
                        height: 13, width: 80, color: AppColors.surface2),
                    const Spacer(),
                    // Progress bar
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(4),
                      ),
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

/// Skeleton for a 2-column courses grid.
class CourseGridShimmer extends StatelessWidget {
  final int count;
  const CourseGridShimmer({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (_, __) => const CourseCardShimmer(),
      ),
    );
  }
}

// ─── Statistics skeletons ─────────────────────────────────────────────────────

/// Skeleton for a stat metric tile (e.g. in Statistics screen).
class StatTileShimmer extends StatelessWidget {
  const StatTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface2,
      highlightColor: AppColors.surface3,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            // Value
            Container(height: 28, width: 60, color: AppColors.surface2),
            const SizedBox(height: 6),
            // Label
            Container(height: 11, width: 80, color: AppColors.surface2),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for a row of 3 stat tiles.
class StatsRowShimmer extends StatelessWidget {
  const StatsRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: StatTileShimmer()),
        SizedBox(width: 12),
        Expanded(child: StatTileShimmer()),
        SizedBox(width: 12),
        Expanded(child: StatTileShimmer()),
      ],
    );
  }
}

// ─── Notification skeleton ────────────────────────────────────────────────────

/// Skeleton for a single notification list item.
class NotificationItemShimmer extends StatelessWidget {
  const NotificationItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface2,
      highlightColor: AppColors.surface3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon circle
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.surface2,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, color: AppColors.surface2),
                  const SizedBox(height: 6),
                  Container(height: 12, width: 200, color: AppColors.surface2),
                  const SizedBox(height: 6),
                  Container(height: 10, width: 80, color: AppColors.surface2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vertical list of [NotificationItemShimmer].
class NotificationListShimmer extends StatelessWidget {
  final int count;
  const NotificationListShimmer({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (_) => const NotificationItemShimmer()),
    );
  }
}

// ─── Profile skeleton ─────────────────────────────────────────────────────────

/// Skeleton for the profile screen header (avatar + name + role).
class ProfileHeaderShimmer extends StatelessWidget {
  const ProfileHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface2,
      highlightColor: AppColors.surface3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            // Avatar
            const SkeletonBox(width: 88, height: 88, borderRadius: 999),
            const SizedBox(height: 16),
            // Name
            const SkeletonBox(width: 160, height: 20, borderRadius: 6),
            const SizedBox(height: 8),
            // Role chip
            const SkeletonBox(width: 80, height: 14, borderRadius: 999),
          ],
        ),
      ),
    );
  }
}
