import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_radius.dart';

class CountdownChip extends StatelessWidget {
  final DateTime dueDate;
  final bool compact;

  const CountdownChip(
      {super.key, required this.dueDate, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final diff = dueDate.difference(DateTime.now());
    final isOverdue = diff.isNegative;
    final isUrgent = !isOverdue && diff.inHours < 24;
    final isWarning = !isOverdue && diff.inDays < 3;

    Color color;
    String label;

    if (isOverdue) {
      color = AppColors.error;
      label = 'Vencida';
    } else if (isUrgent) {
      color = AppColors.error;
      final h = diff.inHours;
      label = h == 0 ? 'Menos de 1h' : 'Vence en ${h}h';
    } else if (isWarning) {
      color = AppColors.warning;
      label = 'Vence en ${diff.inDays}d';
    } else {
      color = AppColors.textSecondary;
      label = DateFormat('d MMM', 'es').format(dueDate);
    }

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, size: 12, color: color),
          const SizedBox(width: AppSpacing.s1),
          Text(label,
              style: tt.labelSmall!.copyWith(
                  color: color, fontWeight: FontWeight.w500)),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s2, vertical: AppSpacing.s1),
      decoration: BoxDecoration(
        color: color.withAlpha(AppAlpha.a10),
        borderRadius: BorderRadius.circular(AppRadius.r2),
        border: Border.all(color: color.withAlpha(AppAlpha.a30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, size: 12, color: color),
          const SizedBox(width: AppSpacing.s1),
          Text(label,
              style: tt.labelSmall!.copyWith(
                  color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
