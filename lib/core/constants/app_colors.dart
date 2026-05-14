import 'package:flutter/material.dart';

/// Central color token system for Captus.
/// All colors in the app must reference tokens from this file.
/// Never use Color(0xFF...) or Colors.xxx directly in UI code.
class AppColors {
  AppColors._();

  // ─── Backgrounds ────────────────────────────────────────────────────────────
  static const Color background         = Color(0xFFF7F7F7); // Scaffold general
  static const Color surface            = Color(0xFFFFFFFF); // Cards, AppBar, BottomNav
  static const Color surface2           = Color(0xFFF2F2F2); // Inputs, chips inactivos, skeleton
  static const Color surface3           = Color(0xFFE8E8E8); // Hover states, separadores

  // ─── Superficies oscuras (shell, modales) ───────────────────────────────────
  static const Color bottomNavBg        = Color(0xFF1A1A1A); // Fondo del BottomNavigationBar
  static const Color modalBg            = Color(0xFF1E1E1E); // Fondo de bottom sheets y modales oscuros

  // ─── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary            = Color(0xFF1DB954); // Verde Captus — acciones principales
  static const Color primaryDark        = Color(0xFF17A148); // Pressed state, logo bg
  static const Color primaryLight       = Color(0xFFE6F9EE); // Badge bg, tint suave, chips activos
  static const Color primaryUltraLight  = Color(0xFFF0FDF5); // Fondos de sección con acento verde muy suave

  // ─── Acentos ────────────────────────────────────────────────────────────────
  static const Color accentPurple       = Color(0xFF7C4DFF); // Materias activas, estadísticas
  static const Color accentAmber        = Color(0xFFFFD54F); // Streak, logros destacados (= streak)

  // ─── Semánticos ─────────────────────────────────────────────────────────────
  static const Color error              = Color(0xFFD32F2F);
  static const Color warning            = Color(0xFFC66900);
  static const Color info               = Color(0xFF1565C0);
  static const Color success            = Color(0xFF1DB954);
  static const Color offline            = Color(0xFFB71C1C); // Estado sin conexión

  /// Fondos semánticos (badges, chips, banners)
  static const Color errorLight         = Color(0xFFFFEBEB);
  static const Color warningLight       = Color(0xFFFFF3E0);
  static const Color infoLight          = Color(0xFFE3F0FF);
  static const Color successLight       = Color(0xFFE6F9EE);

  // ─── Texto ──────────────────────────────────────────────────────────────────
  static const Color textPrimary        = Color(0xFF111111);
  static const Color textSecondary      = Color(0xFF888888);
  static const Color textDisabled       = Color(0xFFBBBBBB);
  static const Color textOnPrimary      = Color(0xFFFFFFFF); // Texto sobre fondo verde o oscuro
  static const Color textOnDark         = Color(0xFFFFFFFF); // Texto sobre fondos oscuros genéricos

  // ─── Bordes ─────────────────────────────────────────────────────────────────
  static const Color divider            = Color(0xFFEEEEEE);
  static const Color border             = Color(0xFFE0E0E0);

  // ─── Prioridades ────────────────────────────────────────────────────────────
  static const Color priorityHigh       = Color(0xFFD32F2F);
  static const Color priorityMedium     = Color(0xFFC66900);
  static const Color priorityLow        = Color(0xFF1DB954);

  static const Color priorityHighBg     = Color(0xFFFFEBEB);
  static const Color priorityMediumBg   = Color(0xFFFFF3E0);
  static const Color priorityLowBg      = Color(0xFFE6F9EE);

  // ─── Streak ─────────────────────────────────────────────────────────────────
  static const Color streak             = Color(0xFFFFD54F);
  static const Color streakText         = Color(0xFF7A4F00);

  // ─── Cursos (colores por materia) ────────────────────────────────────────────
  static const List<Color> courseColors = [
    Color(0xFF7C4DFF), // purple
    Color(0xFF00BCD4), // cyan
    Color(0xFFFF5722), // deep orange
    Color(0xFF4CAF50), // green
    Color(0xFFE91E63), // pink
    Color(0xFF2196F3), // blue
    Color(0xFFFF9800), // orange
    Color(0xFF9C27B0), // purple dark
    Color(0xFF009688), // teal
    Color(0xFFF44336), // red
  ];

  static Color courseColor(int index) =>
      courseColors[index % courseColors.length];
}

/// Opacity constants for use with [Color.withAlpha].
///
/// Use these instead of [Color.withOpacity] or raw [withAlpha] magic numbers
/// to keep opacity intent readable across the codebase.
///
/// Example:
/// ```dart
/// AppColors.primary.withAlpha(AppAlpha.a10)   // 10% — very subtle tint
/// AppColors.error.withAlpha(AppAlpha.a30)      // 30% — moderate overlay
/// ```
class AppAlpha {
  AppAlpha._();

  /// 5%  — barely visible tint (hover backgrounds on light surfaces)
  static const int a05 = 13;

  /// 10% — subtle tint (chip backgrounds, badge fills)
  static const int a10 = 25;

  /// 15% — light tint (course color chip bg, priority badge)
  static const int a15 = 38;

  /// 20% — soft overlay (disabled overlays, inactive states)
  static const int a20 = 51;

  /// 30% — moderate overlay (InkWell ripple, pressed states)
  static const int a30 = 76;

  /// 40% — modal barrier, strong overlays
  static const int a40 = 102;

  /// 50% — half opacity (shadows, secondary indicators)
  static const int a50 = 127;

  /// 60% — prominent overlay
  static const int a60 = 153;

  /// 70% — near-opaque (toast backgrounds, strong banners)
  static const int a70 = 178;

  /// 80% — high opacity (dark overlays)
  static const int a80 = 204;
}
