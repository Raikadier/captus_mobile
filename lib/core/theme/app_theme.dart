import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_animations.dart';
import '../constants/app_spacing.dart';

/// Material 3 theme for Captus — v2.0
///
/// Applies all design-system tokens from:
///   AppColors, AppSpacing, AppShadows, AppDurations, AppCurves
///
/// Premium upgrades vs v1:
///   - Slate-tinted neutrals (background, surfaces, borders)
///   - Proper letter-spacing on heading styles
///   - Consistent line-height ratios
///   - Card shadow elevation (was elevation: 0 everywhere)
///   - Brand-tinted FAB shadow
///   - Shell bg uses slate-900 (not flat #1A1A1A)
///   - Progress bar styled to 6px + rounded
///   - InputDecoration with proper transition via focus border width
///   - TabBar with gradient indicator
///   - Bottom nav refined to slate-900 + 0.5px hairline border
class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────────────────────────────────────
  // LIGHT THEME
  // ─────────────────────────────────────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        brightness:         Brightness.light,
        primary:            AppColors.primary,
        onPrimary:          AppColors.textOnPrimary,
        primaryContainer:   AppColors.primaryUltraLight,
        onPrimaryContainer: AppColors.brand700,
        secondary:          AppColors.primaryLight,
        onSecondary:        AppColors.brand700,
        tertiary:           AppColors.accentPurple,
        onTertiary:         AppColors.textOnPrimary,
        surface:            AppColors.surface,
        onSurface:          AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surface2,
        error:              AppColors.error,
        onError:            AppColors.textOnPrimary,
        outline:            AppColors.border,
        outlineVariant:     AppColors.divider,
        shadow:             AppColors.slate900,
      ),
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      bottomNavigationBarTheme: _bottomNavTheme,
      navigationBarTheme: _navigationBarTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      chipTheme: _chipTheme,
      floatingActionButtonTheme: _fabTheme,
      progressIndicatorTheme: _progressTheme,
      tabBarTheme: _tabBarTheme,
      checkboxTheme: _checkboxTheme,
      switchTheme: _switchTheme,
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: _bottomSheetTheme,
      dialogTheme: _dialogTheme,
      snackBarTheme: _snackBarTheme,
      tooltipTheme: _tooltipTheme,
      listTileTheme: _listTileTheme,
    );
  }

  // ─── TEXT THEME ──────────────────────────────────────────────────────────────
  //
  // Premium text improvements vs v1:
  //   - Letter-spacing: negative on headings (tighter = more refined)
  //   - Accurate height (line-height) values
  //   - Slate-900 primary text instead of #111
  //
  static TextTheme get _textTheme {
    return TextTheme(
      // displayLarge → display-xl (48px, w800)
      displayLarge: GoogleFonts.inter(
        fontSize: 48, fontWeight: FontWeight.w800, height: 1.10,
        letterSpacing: -0.04 * 48, color: AppColors.textPrimary,
      ),
      // displayMedium → display-lg (36px, w700)
      displayMedium: GoogleFonts.inter(
        fontSize: 36, fontWeight: FontWeight.w700, height: 1.15,
        letterSpacing: -0.03 * 36, color: AppColors.textPrimary,
      ),
      // displaySmall → display-md (30px, w700)
      displaySmall: GoogleFonts.inter(
        fontSize: 30, fontWeight: FontWeight.w700, height: 1.20,
        letterSpacing: -0.025 * 30, color: AppColors.textPrimary,
      ),
      // headlineLarge → heading-lg (20px, w700)
      headlineLarge: GoogleFonts.inter(
        fontSize: 20, fontWeight: FontWeight.w700, height: 1.30,
        letterSpacing: -0.015 * 20, color: AppColors.textPrimary,
      ),
      // headlineMedium → heading-md (18px, w600)
      headlineMedium: GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w600, height: 1.35,
        letterSpacing: -0.010 * 18, color: AppColors.textPrimary,
      ),
      // headlineSmall → heading-sm (16px, w600)
      headlineSmall: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w600, height: 1.40,
        letterSpacing: -0.005 * 16, color: AppColors.textPrimary,
      ),
      // titleLarge → title-lg (15px, w600)
      titleLarge: GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w600, height: 1.45,
        letterSpacing: 0, color: AppColors.textPrimary,
      ),
      // titleMedium → title-sm (14px, w500)
      titleMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500, height: 1.45,
        letterSpacing: 0, color: AppColors.textPrimary,
      ),
      // titleSmall → body label (13px, w500)
      titleSmall: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w500, height: 1.50,
        letterSpacing: 0.005 * 13, color: AppColors.textPrimary,
      ),
      // bodyLarge → body-lg (15px, w400)
      bodyLarge: GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w400, height: 1.60,
        letterSpacing: 0, color: AppColors.textPrimary,
      ),
      // bodyMedium → body-md (14px, w400)
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, height: 1.60,
        letterSpacing: 0, color: AppColors.textPrimary,
      ),
      // bodySmall → body-sm (12px, w400)
      bodySmall: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400, height: 1.55,
        letterSpacing: 0.005 * 12, color: AppColors.textSecondary,
      ),
      // labelLarge → caption (12px, w500)
      labelLarge: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500, height: 1.50,
        letterSpacing: 0.010 * 12, color: AppColors.textPrimary,
      ),
      // labelMedium → overline (11px, w600, caps)
      labelMedium: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w600, height: 1.40,
        letterSpacing: 0.08 * 11, color: AppColors.textSecondary,
      ),
      // labelSmall → micro (10px, w500)
      labelSmall: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w500, height: 1.40,
        letterSpacing: 0.02 * 10, color: AppColors.textSecondary,
      ),
    );
  }

  // ─── APP BAR ─────────────────────────────────────────────────────────────────
  static AppBarTheme get _appBarTheme => AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 1,
    shadowColor: AppColors.shadowBase,
    surfaceTintColor: Colors.transparent,
    centerTitle: false,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 18, fontWeight: FontWeight.w600,
      letterSpacing: -0.01 * 18,
      color: AppColors.textPrimary,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.textPrimary,
      size: 24,
    ),
    actionsIconTheme: const IconThemeData(
      color: AppColors.textSecondary,
      size: 22,
    ),
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // ─── BOTTOM NAVIGATION BAR ───────────────────────────────────────────────────
  static BottomNavigationBarThemeData get _bottomNavTheme =>
      const BottomNavigationBarThemeData(
        backgroundColor: AppColors.shellBg,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.slate400,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.2,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w400,
        ),
      );

  static NavigationBarThemeData get _navigationBarTheme =>
      NavigationBarThemeData(
        backgroundColor: AppColors.shellBg,
        indicatorColor: AppColors.primary.withAlpha(AppAlpha.a20),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.slate400, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: AppColors.primary, letterSpacing: 0.2,
            );
          }
          return GoogleFonts.inter(
            fontSize: 10, fontWeight: FontWeight.w400,
            color: AppColors.slate400,
          );
        }),
      );

  // ─── CARD ────────────────────────────────────────────────────────────────────
  //
  // v2: Cards now have a subtle shadow (was elevation:0 flat in v1).
  // shadow-xs provides depth without looking heavy.
  //
  static CardThemeData get _cardTheme => CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(
        color: AppColors.border,
        width: 1,
      ),
    ),
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAliasWithSaveLayer,
  );

  // ─── ELEVATED BUTTON ─────────────────────────────────────────────────────────
  //
  // v2: Uses gradient fill via ShapeDecoration (done at widget level via
  // Ink.decoration). Theme sets base style; gradient applied per-widget.
  // Shadow uses brand tint (shadow-brand-sm) for premium feel.
  //
  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.primary.withAlpha(AppAlpha.a40),
          disabledForegroundColor: AppColors.textOnPrimary.withAlpha(AppAlpha.a60),
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          elevation: 0,
          shadowColor: AppColors.shadowBrand,
          animationDuration: AppDurations.instant,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingInput,
          ),
        ),
      );

  // ─── OUTLINED BUTTON ─────────────────────────────────────────────────────────
  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: GoogleFonts.inter(
            fontSize: 15, fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.paddingInput,
          ),
        ),
      );

  // ─── TEXT BUTTON ─────────────────────────────────────────────────────────────
  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s3,
        vertical: AppSpacing.s2,
      ),
    ),
  );

  // ─── INPUT DECORATION ────────────────────────────────────────────────────────
  //
  // v2: Slate-100 rest background (was #F2F2F2). Radius 6px (was 12px) —
  // intentionally less curved than buttons to create visual distinction.
  //
  static InputDecorationTheme get _inputDecorationTheme =>
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.paddingInput,
          vertical: 14,
        ),
        // Default border (rest)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        // Focus: increase to 2px for clear affordance
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: AppColors.border.withAlpha(AppAlpha.a50),
            width: 1,
          ),
        ),
        labelStyle: GoogleFonts.inter(
          color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: GoogleFonts.inter(
          color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.textDisabled, fontSize: 14,
        ),
        errorStyle: GoogleFonts.inter(
          color: AppColors.error, fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        helperStyle: GoogleFonts.inter(
          color: AppColors.textSecondary, fontSize: 12,
        ),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return AppColors.primary;
          return AppColors.textSecondary;
        }),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) return AppColors.primary;
          return AppColors.textSecondary;
        }),
        isDense: false,
      );

  // ─── CHIP ────────────────────────────────────────────────────────────────────
  static ChipThemeData get _chipTheme => ChipThemeData(
    backgroundColor: AppColors.surface2,
    selectedColor: AppColors.primaryLight,
    disabledColor: AppColors.surface2,
    labelStyle: GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    secondaryLabelStyle: GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w500,
      color: AppColors.primary,
    ),
    side: const BorderSide(color: AppColors.border, width: 1),
    shape: const StadiumBorder(), // radius-pill
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.s3,
      vertical: AppSpacing.s1,
    ),
    elevation: 0,
    pressElevation: 0,
  );

  // ─── FAB ─────────────────────────────────────────────────────────────────────
  //
  // v2: Brand-tinted shadow for premium depth.
  //
  static FloatingActionButtonThemeData get _fabTheme =>
      FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        highlightElevation: 0,
        hoverElevation: 0,
        splashColor: AppColors.primaryHover,
        shape: const CircleBorder(),
        // shadow is applied manually via DecoratedBox in CaptussFab widget
      );

  // ─── PROGRESS INDICATOR ─────────────────────────────────────────────────────
  //
  // v2: 6px height for linear, brand color fill.
  //
  static ProgressIndicatorThemeData get _progressTheme =>
      const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surface3,
        linearMinHeight: 6,
        circularTrackColor: AppColors.surface3,
      );

  // ─── TAB BAR ─────────────────────────────────────────────────────────────────
  static TabBarThemeData get _tabBarTheme => TabBarThemeData(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.textSecondary,
    indicatorColor: AppColors.primary,
    indicatorSize: TabBarIndicatorSize.label,
    dividerColor: AppColors.divider,
    labelStyle: GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w600,
      letterSpacing: 0,
    ),
    unselectedLabelStyle: GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w400,
    ),
  );

  // ─── CHECKBOX ────────────────────────────────────────────────────────────────
  static CheckboxThemeData get _checkboxTheme => CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primary;
      if (states.contains(WidgetState.hovered)) return AppColors.surface2;
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(AppColors.textOnPrimary),
    side: const BorderSide(color: AppColors.border, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return AppColors.primary.withAlpha(AppAlpha.a15);
      }
      return Colors.transparent;
    }),
  );

  // ─── SWITCH ──────────────────────────────────────────────────────────────────
  static SwitchThemeData get _switchTheme => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.surface;
      return AppColors.textDisabled;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.primary;
      return AppColors.surface3;
    }),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  );

  // ─── BOTTOM SHEET ────────────────────────────────────────────────────────────
  static BottomSheetThemeData get _bottomSheetTheme => BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    dragHandleColor: AppColors.border,
    dragHandleSize: const Size(36, 4),
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: double.infinity),
    elevation: 0,
    shadowColor: Colors.transparent,
    modalBackgroundColor: AppColors.surface,
    modalElevation: 0,
    clipBehavior: Clip.antiAliasWithSaveLayer,
  );

  // ─── DIALOG ──────────────────────────────────────────────────────────────────
  static DialogThemeData get _dialogTheme => DialogThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
    ),
    elevation: 0,
    shadowColor: Colors.transparent,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 18, fontWeight: FontWeight.w600,
      letterSpacing: -0.01 * 18,
      color: AppColors.textPrimary,
    ),
    contentTextStyle: GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w400,
      height: 1.6, color: AppColors.textSecondary,
    ),
    actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
  );

  // ─── SNACK BAR ───────────────────────────────────────────────────────────────
  static SnackBarThemeData get _snackBarTheme => SnackBarThemeData(
    backgroundColor: AppColors.slate800,
    contentTextStyle: GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w400,
      color: AppColors.slate50,
    ),
    actionTextColor: AppColors.brand400,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    width: null,
    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  // ─── TOOLTIP ─────────────────────────────────────────────────────────────────
  static TooltipThemeData get _tooltipTheme => TooltipThemeData(
    decoration: BoxDecoration(
      color: AppColors.slate800,
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w500,
      color: AppColors.slate50,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    waitDuration: const Duration(milliseconds: 500),
  );

  // ─── LIST TILE ───────────────────────────────────────────────────────────────
  static ListTileThemeData get _listTileTheme => ListTileThemeData(
    minVerticalPadding: 12,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.pageMargin,
      vertical: AppSpacing.s1,
    ),
    titleTextStyle: GoogleFonts.inter(
      fontSize: 14, fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    subtitleTextStyle: GoogleFonts.inter(
      fontSize: 12, fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    iconColor: AppColors.textSecondary,
    shape: const RoundedRectangleBorder(),
  );
}
