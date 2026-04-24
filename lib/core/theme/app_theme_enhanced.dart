import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System de Captus
/// Define colores, tipografía, componentes reutilizables y estilos
class AppTheme {
  // ━━━ Paleta de Colores ━━━
  static const Color primaryColor = Color(0xFF4F46E5); // Índigo
  static const Color secondaryColor = Color(0xFF06B6D4); // Cyan
  static const Color accentColor = Color(0xFFF59E0B); // Ámbar
  static const Color successColor = Color(0xFF10B981); // Verde
  static const Color errorColor = Color(0xFFEF4444); // Rojo
  static const Color warningColor = Color(0xFFF59E0B); // Ámbar

  static const Color darkBg = Color(0xFF0F172A); // Slate-900
  static const Color darkCard = Color(0xFF1E293B); // Slate-800
  static const Color darkText = Color(0xFFF1F5F9); // Slate-100

  static const Color lightBg = Color(0xFFF8FAFC); // Slate-50
  static const Color lightCard = Color(0xFFFFFFFF); // White
  static const Color lightText = Color(0xFF1E293B); // Slate-800

  // ━━━ Tema Oscuro ━━━
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: darkCard,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkCard,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
      ),
      cardTheme: CardTheme(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: _buildTextTheme(Colors.white),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: primaryColor),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF334155), // Slate-700
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: Colors.grey[400]),
        hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
      ),
    );
  }

  // ━━━ Tema Claro ━━━
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: lightCard,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightCard,
        foregroundColor: lightText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: lightText,
        ),
      ),
      cardTheme: CardTheme(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: _buildTextTheme(const Color(0xFF1E293B)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: primaryColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9), // Slate-100
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: Colors.grey[700]),
        hintStyle: GoogleFonts.inter(color: Colors.grey[600]),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color color) {
    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: color,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }
}

/// Componentes personalizados reutilizables

/// Card personalizada de Captus
class CaptusCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final double borderRadius;
  final VoidCallback? onTap;

  const CaptusCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderRadius = 12,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Botón principal personalizado
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;

  const PrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}

/// Cargador con shimmer
class ShimmerLoader extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const ShimmerLoader({
    Key? key,
    this.height = 20,
    this.width = double.infinity,
    this.borderRadius = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[200],
      ),
    );
  }
}
