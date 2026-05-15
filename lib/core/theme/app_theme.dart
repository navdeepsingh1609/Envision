import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ultra-Vibrant Liquid Palette for 2026
  static const Color primaryColor = Color(0xFF6366F1); // Modern Indigo
  static const Color accentColor = Color(0xFFA855F7);  // Electric Purple
  static const Color infoColor = Color(0xFF0EA5E9);    // Bright Blue
  static const Color successColor = Color(0xFF10B981); // Emerald Green
  static const Color warningColor = Color(0xFFF59E0B); // Golden Amber
  static const Color errorColor = Color(0xFFEF4444);   // Vibrant Red
  static const Color surfaceColor = Color(0xFF020617); // Deepest Slate
  
  static const Color primary = primaryColor;
  static const Color accent = accentColor;
  static const Color surface = surfaceColor;

  // Animation Constants
  static const Duration animDuration = Duration(milliseconds: 800);
  static const Curve animCurve = Curves.elasticOut;
  static const Duration defaultDuration = Duration(milliseconds: 400);
  static const Curve defaultCurve = Curves.easeOutQuart;

  static ThemeData get theme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);
    
    // Modern High-Contrast Typography Hierarchy
    final textTheme = baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.0),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
      titleLarge: baseTextTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.2),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.6, letterSpacing: 0.2),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.5, color: Colors.white70),
      labelSmall: baseTextTheme.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white38),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent, 
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
      ),
      // Set Global Font Fallback to handle Emojis across all platforms (especially Web)
      fontFamilyFallback: const [
        'Apple Color Emoji',
        'Segoe UI Emoji',
        'Noto Color Emoji',
        'Noto Sans',
      ],
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
          color: Colors.white,
        ),
      ),
    );
  }

  static BoxDecoration get backgroundGradient => const BoxDecoration(
    color: surfaceColor,
  );

  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width > 900;
}
