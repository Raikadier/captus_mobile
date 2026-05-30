/// Spacing token system for Captus — v2.0
///
/// Base grid: 4px. Every value is a multiple of 4.
/// Use named tokens instead of raw double literals in UI code.
///
/// Reference: CAPTUS_DESIGN_SYSTEM.md §3
class AppSpacing {
  AppSpacing._();

  // ─── BASE GRID ──────────────────────────────────────────────────────────────
  static const double unit = 4.0;

  // ─── SCALE ──────────────────────────────────────────────────────────────────
  static const double s0  = 0.0;    //  0px
  static const double s1  = 4.0;    //  4px — gaps mínimos inline (icon→label)
  static const double s2  = 8.0;    //  8px — gaps pequeños, padding badge/chip
  static const double s3  = 12.0;   // 12px — padding interno compact (botones sm)
  static const double s4  = 16.0;   // 16px — padding estándar (input, card compact)
  static const double s5  = 20.0;   // 20px — padding cómodo (card standard)
  static const double s6  = 24.0;   // 24px — gap entre cards, sección interna
  static const double s7  = 28.0;   // 28px — gap modal, dialogs compactos
  static const double s8  = 32.0;   // 32px — gap grande, padding de sección
  static const double s10 = 40.0;   // 40px — gap de página
  static const double s12 = 48.0;   // 48px — padding hero
  static const double s14 = 56.0;   // 56px — list items, AppBar height
  static const double s16 = 64.0;   // 64px — margen de página
  static const double s20 = 80.0;   // 80px — padding de sección vertical
  static const double s25 = 100.0;  // 100px — hero images compact

  // ─── NAMED ALIASES (léxico de uso) ─────────────────────────────────────────

  /// Espacio mínimo entre elementos inline
  static const double iconGap = s1;       // 4px

  /// Gap entre ícono y etiqueta
  static const double iconLabelGap = s2;  // 8px

  /// Padding interno componentes compactos (badge, chip)
  static const double paddingChip = s2;   // 8px h, 4px v

  /// Padding horizontal botón/input
  static const double paddingInput = s4;  // 16px

  /// Padding interno card compact
  static const double cardPaddingCompact = s4; // 16px

  /// Padding interno card estándar
  static const double cardPaddingStd = s5;     // 20px

  /// Padding interno card cómodo
  static const double cardPaddingLarge = s6;   // 24px

  /// Gap entre cards en lista
  static const double cardGap = s3;            // 12px

  /// Gap entre secciones dentro de pantalla
  static const double sectionGap = s6;         // 24px

  /// Margen horizontal de página (pantallas ≥375px)
  static const double pageMargin = s5;         // 20px

  /// Margen horizontal de página (pantallas <375px)
  static const double pageMarginSm = s4;       // 16px

  // ─── LAYOUT ─────────────────────────────────────────────────────────────────

  /// Altura de AppBar
  static const double appBarHeight = s14;      // 56px

  /// Altura del BottomNavigationBar (sin safe area)
  static const double bottomNavHeight = s16;   // 64px

  /// Altura mínima de touch target (Apple HIG)
  static const double touchTargetMin = 44.0;

  /// Altura estándar de list item
  static const double listItemHeight = s14;    // 56px

  /// Altura de input field estándar
  static const double inputHeight = s12;       // 48px

  /// Altura de botón estándar
  static const double buttonHeight = 44.0;

  /// Altura de botón grande (full-width CTA)
  static const double buttonHeightLg = 52.0;
}
