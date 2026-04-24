import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Backgrounds ────────────────────────────────────────────────────────────
  static const Color background  = Color(0xFFF7F7F7); // fondo general
  static const Color surface     = Color(0xFFFFFFFF); // cards, modals
  static const Color surface2    = Color(0xFFF2F2F2); // inputs, chips inactivos
  static const Color surface3    = Color(0xFFE8E8E8); // hover, separadores

  // ─── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF1DB954); // verde Captus
  static const Color primaryDark  = Color(0xFF17A148); // pressed / logo bg
  static const Color primaryLight = Color(0xFFE6F9EE); // badge bg, tint suave

  // ─── Semánticos ─────────────────────────────────────────────────────────────
  static const Color error   = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFC66900);
  static const Color info    = Color(0xFF1565C0);
  static const Color success = Color(0xFF1DB954);

  // Fondos semánticos (para badges / chips)
  static const Color errorLight   = Color(0xFFFFEBEB);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color infoLight    = Color(0xFFE3F0FF);
  static const Color successLight = Color(0xFFE6F9EE);

  // ─── Texto ──────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textDisabled  = Color(0xFFBBBBBB);
  static const Color textOnPrimary = Color(0xFFFFFFFF); // texto sobre verde

  // ─── Bordes ─────────────────────────────────────────────────────────────────
  static const Color divider = Color(0xFFEEEEEE);
  static const Color border  = Color(0xFFE0E0E0);

  // ─── Prioridades ────────────────────────────────────────────────────────────
  static const Color priorityHigh   = Color(0xFFD32F2F);
  static const Color priorityMedium = Color(0xFFC66900);
  static const Color priorityLow    = Color(0xFF1DB954);

  static const Color priorityHighBg   = Color(0xFFFFEBEB);
  static const Color priorityMediumBg = Color(0xFFFFF3E0);
  static const Color priorityLowBg    = Color(0xFFE6F9EE);

  // ─── Streak ─────────────────────────────────────────────────────────────────
  static const Color streak     = Color(0xFFFFD54F);
  static const Color streakText = Color(0xFF7A4F00);

  // ─── Cursos (colores por materia) ────────────────────────────────────────────
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
