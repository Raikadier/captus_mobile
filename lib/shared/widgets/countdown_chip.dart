import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';

class CountdownChip extends StatelessWidget {
  final DateTime dueDate;
  final bool compact;

  const CountdownChip({super.key, required this.dueDate, this.compact = false});

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(width: 3),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
