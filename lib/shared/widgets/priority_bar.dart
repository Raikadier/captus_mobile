import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task.dart';
import '../../core/constants/app_radius.dart';

class PriorityBar extends StatelessWidget {
  final TaskPriority priority;
  final double width;

  const PriorityBar({super.key, required this.priority, this.width = 4});

  Color get color {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppRadius.r5),
          bottomLeft: Radius.circular(AppRadius.r5),
        ),
      ),
    );
  }
}
