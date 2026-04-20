import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surface2 = Color(0xFF2A2A2A);
  static const Color surface3 = Color(0xFF333333);

  static const Color primary = Color(0xFF00C853);
  static const Color primaryDark = Color(0xFF1E3A2F);
  static const Color primaryLight = Color(0xFF69F0AE);

  static const Color error = Color(0xFFFF4444);
  static const Color warning = Color(0xFFFFAB00);
  static const Color info = Color(0xFF448AFF);
  static const Color success = Color(0xFF00C853);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textDisabled = Color(0xFF666666);

  static const Color divider = Color(0xFF2A2A2A);
  static const Color border = Color(0xFF3A3A3A);

  // Priority colors
  static const Color priorityHigh = Color(0xFFFF4444);
  static const Color priorityMedium = Color(0xFFFFAB00);
  static const Color priorityLow = Color(0xFF00C853);

  // Course colors (one per subject)
  static const List<Color> courseColors = [
    Color(0xFF7C4DFF),
    Color(0xFF00BCD4),
    Color(0xFFFF5722),
    Color(0xFF4CAF50),
    Color(0xFFE91E63),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFF9C27B0),
    Color(0xFF009688),
    Color(0xFFF44336),
  ];

  static Color courseColor(int index) =>
      courseColors[index % courseColors.length];
}
