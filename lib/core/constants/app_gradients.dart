import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Gradient token system for Captus — v2.0
///
/// Rules:
///   1. Use gradients intentionally — only for hero/CTA elements.
///   2. Brand gradient on FAB and primary buttons (not on body text).
///   3. Shimmer gradient only for skeleton loading.
///
/// Reference: CAPTUS_DESIGN_SYSTEM.md §7
class AppGradients {
  AppGradients._();

  // ─── BRAND ──────────────────────────────────────────────────────────────────

  /// Primary CTA gradient — FAB, primary buttons, active progress
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.brand500, AppColors.brand600],
    stops: [0.0, 1.0],
  );

  /// Hero gradient — achievement headers, streak hero, onboarding
  static const LinearGradient brandHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.brand400, AppColors.brand700],
    stops: [0.0, 1.0],
  );

  // ─── ACCENT ─────────────────────────────────────────────────────────────────

  /// Brand × Violet — logros especiales, materias activas, perfil
  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.violet500, AppColors.brand500],
    stops: [0.0, 1.0],
  );

  // ─── STREAK ─────────────────────────────────────────────────────────────────

  /// Amber gradient — streak badge, achievement unlock
  static const LinearGradient streak = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.amber400, AppColors.amber500],
    stops: [0.0, 1.0],
  );

  // ─── NEUTRAL ────────────────────────────────────────────────────────────────

  /// Subtle surface fade — card backgrounds, section dividers
  static const LinearGradient surface = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), AppColors.slate50],
    stops: [0.0, 1.0],
  );

  /// Hero section background — light radial glow in center
  static const RadialGradient surfaceHero = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.2,
    colors: [AppColors.brand50, AppColors.slate50],
    stops: [0.0, 1.0],
  );

  // ─── SKELETON / SHIMMER ─────────────────────────────────────────────────────

  /// Sweep used in skeleton loading (LoadingShimmer widget)
  static const LinearGradient shimmer = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0x00F1F5F9), // transparent
      Color(0xCCF1F5F9), // slate-100 / 80%
      Color(0x00F1F5F9), // transparent
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Shimmer for dark mode
  static const LinearGradient shimmerDark = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0x00334155), // transparent
      Color(0xCC334155), // slate-700 / 80%
      Color(0x00334155), // transparent
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // ─── COURSE AVATAR FALLBACK ─────────────────────────────────────────────────

  /// Returns a gradient for course/avatar fallback based on a hash index
  static LinearGradient courseGradient(int index) {
    final gradients = _courseGradients;
    return gradients[index % gradients.length];
  }

  static const List<LinearGradient> _courseGradients = [
    LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF0891B2), Color(0xFF0E7490)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFEA580C), Color(0xFFC2410C)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [AppColors.brand500, AppColors.brand700],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFDB2777), Color(0xFFBE185D)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [AppColors.amber500, Color(0xFFD97706)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF9333EA), Color(0xFF7E22CE)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
  ];
}
