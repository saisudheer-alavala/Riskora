import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- DARK THEME TOKENS (Calibrated Deep Obsidian Stealth - No Glare) ---
  static const Color darkBackground = Color(0xFF0D0C15); // Deep stealth canvas
  static const Color darkBackgroundCanvas = Color(0xFF12111D); // Secondary canvas
  static const Color darkSurface = Color(0xFF181726); // Deep card surface (toned down from glare)
  static const Color darkSurfaceElevated = Color(0xFF212030); // Elevated surface
  static const Color darkSurfaceHigh = Color(0xFF2A283C); // Modals & popup sheets
  static const Color darkBorder = Color(0xFF2C2A3E); // Crisp subtle border
  static const Color darkBorderSubtle = Color(0xFF201F2F); // Divider lines
  static const Color darkTextPrimary = Color(0xFFF3F4F6); // Soft bright text
  static const Color darkTextSecondary = Color(0xFF9CA3AF); // Muted secondary
  static const Color darkTextMuted = Color(0xFF6B7280); // Subtle captions

  // --- LIGHT THEME TOKENS (Clean Enterprise Precision) ---
  static const Color lightBackground = Color(0xFFF4F6FB); // Soft enterprise canvas
  static const Color lightBackgroundCanvas = Color(0xFFEBF0F8);
  static const Color lightSurface = Color(0xFFFFFFFF); // Crisp clean white cards
  static const Color lightSurfaceElevated = Color(0xFFF0F4FA);
  static const Color lightSurfaceHigh = Color(0xFFE5ECF6);
  static const Color lightBorder = Color(0xFFDCE3EF);
  static const Color lightBorderSubtle = Color(0xFFE9EFF7);
  static const Color lightTextPrimary = Color(0xFF0F172A); // Deep slate navy
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Active theme flag (synchronized with AppStateProvider)
  static bool currentIsDark = true;

  // Dynamic getters that adapt automatically based on the active theme
  static Color get background => currentIsDark ? darkBackground : lightBackground;
  static Color get backgroundCanvas => currentIsDark ? darkBackgroundCanvas : lightBackgroundCanvas;
  static Color get surface => currentIsDark ? darkSurface : lightSurface;
  static Color get surfaceElevated => currentIsDark ? darkSurfaceElevated : lightSurfaceElevated;
  static Color get surfaceHigh => currentIsDark ? darkSurfaceHigh : lightSurfaceHigh;
  static Color get border => currentIsDark ? darkBorder : lightBorder;
  static Color get borderSubtle => currentIsDark ? darkBorderSubtle : lightBorderSubtle;
  static Color get textPrimary => currentIsDark ? darkTextPrimary : lightTextPrimary;
  static Color get textSecondary => currentIsDark ? darkTextSecondary : lightTextSecondary;
  static Color get textMuted => currentIsDark ? darkTextMuted : lightTextMuted;

  // --- SIGNATURE ACCENTS & GRADIENTS (Red Points Electric Palette) ---
  static const Color purpleElectric = Color(0xFF5D2EE6); // Red Points Electric Indigo
  static const Color purpleGlow = Color(0xFF7E47FF); // Red Points signature purple
  static const Color magentaRoyal = Color(0xFF783291); // Mid-magenta
  static const Color magentaGlow = Color(0xFFAA46CE); // Bright violet
  static const Color coralSunset = Color(0xFFFF9B63); // Red Points Sunset Coral
  static const Color coralDark = Color(0xFFE8743A); // Orange dark

  // Primary Brand Accents (Electric Purple - NO GREEN ON BUTTONS)
  static const Color primaryTeal = Color(0xFF7E47FF);
  static const Color primaryTealLight = Color(0xFFA078FF);
  static const Color mintGreen = Color(0xFF10B981); // Reserved strictly for positive status tags
  static const Color mintGreenLight = Color(0xFF34D399);

  // Status Indicators
  static const Color riskCritical = Color(0xFFFF7474); // Red
  static const Color riskHigh = Color(0xFFE8743A); // Orange
  static const Color riskMedium = Color(0xFFFF9B63); // Salmon / Coral
  static const Color riskLow = Color(0xFF818CF8); // Slate Indigo (No Green)
  static const Color riskInfo = Color(0xFF7E47FF); // Purple

  // Signature Gradients
  static const LinearGradient redPointsGradient = LinearGradient(
    colors: [Color(0xFF5D2EE6), Color(0xFF783291), Color(0xFFFF9B63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redPointsDarkGradient = LinearGradient(
    colors: [Color(0xFF5061FF), Color(0xFFAA46CE), Color(0xFFFF9B63)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Softened Ambient Shadows (Eliminating harsh glow glare)
  static List<BoxShadow> get darkCardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.35),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadow => currentIsDark ? darkCardShadow : lightCardShadow;

  static List<BoxShadow> get lightCardShadow => [
        BoxShadow(
          color: const Color(0xFF64748B).withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ];

  static List<BoxShadow> glowTeal([double opacity = 0.18]) => [
        BoxShadow(
          color: purpleGlow.withOpacity(opacity),
          blurRadius: 14,
          spreadRadius: 1,
        ),
      ];

  static List<BoxShadow> glowPurple([double opacity = 0.20]) => [
        BoxShadow(
          color: purpleElectric.withOpacity(opacity),
          blurRadius: 14,
          spreadRadius: 1,
        ),
      ];

  static List<BoxShadow> glowRisk([Color color = riskCritical, double opacity = 0.20]) => [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: 12,
          spreadRadius: 1,
        ),
      ];

  // ==========================================
  // --- 1. DARK THEME DEFINITION (STEALTH) ---
  // ==========================================
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: purpleGlow,
      canvasColor: darkSurface,
      cardColor: darkSurface,
      dividerColor: darkBorderSubtle,
      colorScheme: const ColorScheme.dark(
        primary: purpleGlow,
        secondary: coralSunset,
        surface: darkSurface,
        error: riskCritical,
        onPrimary: Colors.white,
        onSecondary: Color(0xFF0D0C15),
        onSurface: darkTextPrimary,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface.withOpacity(0.95),
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: darkTextPrimary),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(color: darkTextMuted, fontSize: 13),
        labelStyle: GoogleFonts.inter(color: darkTextSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: purpleGlow, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: riskCritical, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: purpleGlow,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: purpleGlow,
          side: const BorderSide(color: purpleGlow, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: coralSunset,
          textStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceElevated,
        disabledColor: darkSurface,
        selectedColor: purpleElectric.withOpacity(0.25),
        secondarySelectedColor: purpleGlow,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: GoogleFonts.inter(fontSize: 12, color: darkTextSecondary),
        secondaryLabelStyle: GoogleFonts.inter(fontSize: 12, color: coralSunset),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: darkBorder, width: 0.8),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1.2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurfaceHigh,
        contentTextStyle: GoogleFonts.inter(color: darkTextPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================
  // --- 2. LIGHT THEME DEFINITION (CLEAN) ----
  // ==========================================
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: purpleElectric,
      canvasColor: lightSurface,
      cardColor: lightSurface,
      dividerColor: lightBorderSubtle,
      colorScheme: const ColorScheme.light(
        primary: purpleElectric,
        secondary: coralDark,
        surface: lightSurface,
        error: riskCritical,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: lightTextPrimary,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: lightTextPrimary,
          letterSpacing: -0.3,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: lightTextPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: lightTextPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: lightTextSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: lightTextMuted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightSurface.withOpacity(0.96),
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: lightTextPrimary),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: lightTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(color: lightTextMuted, fontSize: 13),
        labelStyle: GoogleFonts.inter(color: lightTextSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: purpleElectric, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: riskCritical, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: purpleElectric,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: purpleElectric,
          side: const BorderSide(color: purpleElectric, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: coralDark,
          textStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: lightSurfaceElevated,
        disabledColor: lightSurface,
        selectedColor: purpleElectric.withOpacity(0.15),
        secondarySelectedColor: purpleElectric,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        labelStyle: GoogleFonts.inter(fontSize: 12, color: lightTextSecondary),
        secondaryLabelStyle: GoogleFonts.inter(fontSize: 12, color: coralDark),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: lightBorder, width: 0.8),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder, width: 1.0),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightSurfaceHigh,
        contentTextStyle: GoogleFonts.inter(color: lightTextPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Code / Hash typography
  static TextStyle monoStyle({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textSecondary,
      letterSpacing: 0.2,
    );
  }
}
