import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/task.dart';

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
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
      ),
    );
  }
}
