import 'package:flutter/material.dart';

/// Central color token system for Captus — v2.0
///
/// Token hierarchy:
///   Primitives (brand-*, slate-*, violet-*, amber-*) →
///   Semantic aliases (primary, surface, textPrimary...) →
///   Component tokens (AppColors.X)
///
/// Rules:
///   1. Never use Color(0xFF...) or Colors.xxx directly in UI code.
///   2. Always reference tokens — primitives for tonal scale, semantic for UI.
///   3. Dark-mode counterparts defined separately in AppColorsDark.
///
/// Reference: CAPTUS_DESIGN_SYSTEM.md §1
class AppColors {
  AppColors._();

  // ─── PRIMITIVE SCALE — Brand (Emerald / Green Captus) ──────────────────────
  //
  // Hue 148° · OKLCH-aligned tonal ramp around #1DB954 (brand identity)
  //
  static const Color brand50  = Color(0xFFECFDF5); // oklch(0.97 0.05 148)
  static const Color brand100 = Color(0xFFD1FAE5); // oklch(0.94 0.08 148)
  static const Color brand200 = Color(0xFFA7F3D0); // oklch(0.89 0.11 148)
  static const Color brand300 = Color(0xFF6EE7B7); // oklch(0.83 0.13 148)
  static const Color brand400 = Color(0xFF34D399); // oklch(0.76 0.14 148)
  static const Color brand500 = Color(0xFF1DB954); // oklch(0.65 0.15 148) ← BRAND
  static const Color brand600 = Color(0xFF17A148); // oklch(0.58 0.15 148)
  static const Color brand700 = Color(0xFF138A3A); // oklch(0.51 0.14 148)
  static const Color brand800 = Color(0xFF0F6B2D); // oklch(0.42 0.12 148)
  static const Color brand900 = Color(0xFF0A4E20); // oklch(0.32 0.09 148)
  static const Color brand950 = Color(0xFF052E12); // oklch(0.20 0.06 148)

  // ─── PRIMITIVE SCALE — Slate (neutral, warm-blue undertone) ────────────────
  //
  // Slate gives a sharper, more premium feel than pure gray.
  // Used for all neutral surfaces, text, borders.
  //
  static const Color slate50  = Color(0xFFF8FAFC); // oklch(0.985 0.005 246)
  static const Color slate100 = Color(0xFFF1F5F9); // oklch(0.967 0.007 246)
  static const Color slate200 = Color(0xFFE2E8F0); // oklch(0.922 0.013 246)
  static const Color slate300 = Color(0xFFCBD5E1); // oklch(0.865 0.020 246)
  static const Color slate400 = Color(0xFF94A3B8); // oklch(0.712 0.032 246)
  static const Color slate500 = Color(0xFF64748B); // oklch(0.556 0.038 246)
  static const Color slate600 = Color(0xFF475569); // oklch(0.462 0.040 246)
  static const Color slate700 = Color(0xFF334155); // oklch(0.360 0.037 246)
  static const Color slate800 = Color(0xFF1E293B); // oklch(0.249 0.035 246)
  static const Color slate900 = Color(0xFF0F172A); // oklch(0.160 0.030 246)
  static const Color slate950 = Color(0xFF020617); // oklch(0.075 0.020 246)

  // ─── PRIMITIVE SCALE — Violet (accent) ──────────────────────────────────────
  static const Color violet100 = Color(0xFFEDE9FE); // oklch(0.94 0.06 285)
  static const Color violet200 = Color(0xFFDDD6FE); // oklch(0.89 0.10 285)
  static const Color violet500 = Color(0xFF7C3AED); // oklch(0.52 0.21 285)
  static const Color violet600 = Color(0xFF6D28D9); // oklch(0.46 0.20 285)

  // ─── PRIMITIVE SCALE — Amber (streak, gamification) ────────────────────────
  static const Color amber100 = Color(0xFFFEF3C7); // oklch(0.96 0.09 90)
  static const Color amber400 = Color(0xFFFBBF24); // oklch(0.83 0.17 90)
  static const Color amber500 = Color(0xFFF59E0B); // oklch(0.75 0.17 90)
  static const Color amber800 = Color(0xFF92400E); // oklch(0.42 0.12 60)

  // ─── SEMANTIC TOKENS — Backgrounds / Surfaces ──────────────────────────────
  static const Color background  = slate50;   // Scaffold general
  static const Color surface     = Color(0xFFFFFFFF); // Cards, AppBar, sheets
  static const Color surface2    = slate100;  // Inputs rest, chips inactivos, skeleton
  static const Color surface3    = slate200;  // Hover, separadores

  // ─── SEMANTIC TOKENS — Shell (always dark) ──────────────────────────────────
  static const Color shellBg     = slate900;  // Bottom nav background
  static const Color shellSurface= slate800;  // Bottom nav elevated / modal bg
  static const Color modalBg     = slate800;  // Bottom sheets y modales oscuros

  // ─── SEMANTIC TOKENS — Brand / Primary ─────────────────────────────────────
  static const Color primary          = brand500; // Verde Captus — acciones principales
  static const Color primaryHover     = brand600; // Hover / pressed state
  static const Color primaryActive    = brand700; // Active (deeply pressed)
  static const Color primaryLight     = brand100; // Badge bg, tint suave, chips activos
  static const Color primaryUltraLight= brand50;  // Fondos de sección verde
  static const Color primaryDark      = brand600; // (alias legacy para compat.)

  // ─── SEMANTIC TOKENS — Accent ───────────────────────────────────────────────
  static const Color accentPurple     = violet500; // Materias activas, estadísticas
  static const Color accentPurpleLight= violet100;
  static const Color accentAmber      = amber500; // Streak, logros

  // ─── SEMANTIC TOKENS — Text ────────────────────────────────────────────────
  static const Color textPrimary   = slate900;  // Texto principal
  static const Color textSecondary = slate500;  // Texto secundario / iconos
  static const Color textDisabled  = slate400;  // Deshabilitados, placeholders
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Sobre fondo verde
  static const Color textOnDark    = Color(0xFFFFFFFF); // Sobre fondos oscuros
  static const Color textInverse   = slate50;   // Texto en superficies oscuras

  // ─── SEMANTIC TOKENS — Borders ─────────────────────────────────────────────
  static const Color border       = slate200; // Borde estándar de componente
  static const Color borderStrong = slate300; // Borde de énfasis
  static const Color divider      = slate100; // Líneas divisoras muy sutiles

  // ─── SEMANTIC TOKENS — Status ──────────────────────────────────────────────
  static const Color error        = Color(0xFFDC2626); // oklch(0.55 0.22 29)
  static const Color errorLight   = Color(0xFFFEF2F2);
  static const Color warning      = Color(0xFFD97706); // oklch(0.63 0.17 60)
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color info         = Color(0xFF2563EB); // oklch(0.51 0.22 264)
  static const Color infoLight    = Color(0xFFEFF6FF);
  static const Color success      = brand600;
  static const Color successLight = brand50;
  static const Color offline      = Color(0xFFB91C1C);

  // ─── SEMANTIC TOKENS — Priority ────────────────────────────────────────────
  static const Color priorityHigh      = Color(0xFFDC2626);
  static const Color priorityHighBg    = Color(0xFFFEF2F2);
  static const Color priorityMedium    = Color(0xFFD97706);
  static const Color priorityMediumBg  = Color(0xFFFFFBEB);
  static const Color priorityLow       = brand500;
  static const Color priorityLowBg     = brand50;

  // ─── SEMANTIC TOKENS — Streak ──────────────────────────────────────────────
  static const Color streak      = amber500;
  static const Color streakLight = amber100;
  static const Color streakText  = amber800;

  // ─── CURSO COLORS — Tonal ramp de identidad por materia ────────────────────
  static const List<Color> courseColors = [
    violet500,            // morado
    Color(0xFF0891B2),    // cyan-600
    Color(0xFFEA580C),    // orange-600
    brand600,             // emerald-600
    Color(0xFFDB2777),    // pink-600
    Color(0xFF2563EB),    // blue-600
    Color(0xFFF59E0B),    // amber-500
    Color(0xFF9333EA),    // purple-600
    Color(0xFF0D9488),    // teal-600
    Color(0xFFDC2626),    // red-600
  ];

  static Color courseColor(int index) =>
      courseColors[index % courseColors.length];

  // ─── SOMBRA BASE — rgba del texto oscuro para BoxShadow ────────────────────
  //
  // Usar AppShadows para los BoxShadow completos.
  // Estos son los colores base del sistema de sombras.
  //
  static const Color _shadowBase  = Color(0x0A0F172A); // rgba(15,23,42, 0.04)
  static const Color _shadowDark  = Color(0x140F172A); // rgba(15,23,42, 0.08)
  static const Color _shadowBrand = Color(0x3D1DB954); // rgba(29,185,84, 0.24)

  // (expuestos para AppShadows)
  static Color get shadowBase  => _shadowBase;
  static Color get shadowDark  => _shadowDark;
  static Color get shadowBrand => _shadowBrand;
}

/// Opacity constants for use with [Color.withAlpha].
///
/// Prefer named constants over magic numbers.
/// Example: AppColors.primary.withAlpha(AppAlpha.a10)
class AppAlpha {
  AppAlpha._();

  static const int a04 = 10;   //  4% — hairline shadow
  static const int a05 = 13;   //  5% — hover tint
  static const int a08 = 20;   //  8% — border subtle
  static const int a10 = 25;   // 10% — chip bg, badge fill
  static const int a12 = 30;   // 12% — brand shadow ring
  static const int a15 = 38;   // 15% — priority badge
  static const int a20 = 51;   // 20% — overlay disabled
  static const int a24 = 61;   // 24% — brand shadow primary
  static const int a30 = 76;   // 30% — ripple, pressed
  static const int a35 = 89;   // 35% — modal barrier light
  static const int a40 = 102;  // 40% — modal barrier
  static const int a50 = 127;  // 50% — indicators, split
  static const int a60 = 153;  // 60% — prominent overlay
  static const int a70 = 178;  // 70% — toast bg
  static const int a80 = 204;  // 80% — dark overlay
}
