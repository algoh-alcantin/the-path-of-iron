import 'package:flutter/material.dart';

class SamuraiColors {
  // Primary Colors - Deep Traditional Tones
  static const Color sanguineRed = Color(0xFF8B0000);      // Dried blood on steel
  static const Color midnightBlack = Color(0xFF0D1117);    // Moonless night
  static const Color ironGray = Color(0xFF2F3437);         // Tempered steel
  static const Color ashWhite = Color(0xFFF8F8F2);         // Cherry blossom petals

  // Accent Colors - Spiritual Elements
  static const Color sakuraPink = Color(0xFFFFB7C5);       // Cherry blossom
  static const Color jadeFoliage = Color(0xFF4A5D23);      // Bamboo forest
  static const Color goldenKoi = Color(0xFFFFD700);        // Temple gold
  static const Color mysticPurple = Color(0xFF6A4C93);     // Twilight meditation

  // Status Colors - Emotional States
  static const Color honorableGreen = Color(0xFF228B22);   // Successful lift completion
  static const Color shamefulRed = Color(0xFFDC143C);      // Failed attempt/warning
  static const Color contemplativeBlue = Color(0xFF4682B4); // Rest periods/reflection
  static const Color courageOrange = Color(0xFFFF6347);    // Personal record territory
}

class SamuraiTextStyles {
  // Primary Font: Sharp, angular for strength metrics
  static TextStyle katanaSharp({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w700,
    Color color = SamuraiColors.ashWhite,
  }) => TextStyle(
    fontFamily: 'monospace',
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: 1.5,
    height: 1.2,
  );

  // Secondary Font: Elegant for navigation and labels
  static TextStyle brushStroke({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = SamuraiColors.ashWhite,
  }) => TextStyle(
    fontFamily: 'sans-serif',
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: 0.8,
    height: 1.4,
  );

  // Accent Font: Traditional for wisdom quotes and philosophy
  static TextStyle ancientWisdom({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w300,
    Color color = SamuraiColors.ashWhite,
    FontStyle fontStyle = FontStyle.italic,
  }) => TextStyle(
    fontFamily: 'serif',
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    fontStyle: fontStyle,
    letterSpacing: 0.5,
  );
}

class SamuraiTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: SamuraiColors.sanguineRed,
      scaffoldBackgroundColor: SamuraiColors.midnightBlack,
      colorScheme: const ColorScheme.dark(
        primary: SamuraiColors.sanguineRed,
        secondary: SamuraiColors.goldenKoi,
        surface: SamuraiColors.ironGray,
        onPrimary: SamuraiColors.ashWhite,
        onSecondary: SamuraiColors.midnightBlack,
        onSurface: SamuraiColors.ashWhite,
      ),
      textTheme: TextTheme(
        displayLarge: SamuraiTextStyles.katanaSharp(fontSize: 32),
        displayMedium: SamuraiTextStyles.katanaSharp(fontSize: 28),
        displaySmall: SamuraiTextStyles.katanaSharp(fontSize: 24),
        headlineLarge: SamuraiTextStyles.brushStroke(fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium: SamuraiTextStyles.brushStroke(fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: SamuraiTextStyles.brushStroke(fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: SamuraiTextStyles.brushStroke(fontSize: 16, fontWeight: FontWeight.w500),
        titleMedium: SamuraiTextStyles.brushStroke(fontSize: 14, fontWeight: FontWeight.w500),
        titleSmall: SamuraiTextStyles.brushStroke(fontSize: 12, fontWeight: FontWeight.w500),
        bodyLarge: SamuraiTextStyles.brushStroke(fontSize: 16),
        bodyMedium: SamuraiTextStyles.brushStroke(fontSize: 14),
        bodySmall: SamuraiTextStyles.brushStroke(fontSize: 12),
        labelLarge: SamuraiTextStyles.ancientWisdom(fontSize: 14),
        labelMedium: SamuraiTextStyles.ancientWisdom(fontSize: 12),
        labelSmall: SamuraiTextStyles.ancientWisdom(fontSize: 10),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: SamuraiColors.midnightBlack,
        foregroundColor: SamuraiColors.ashWhite,
        elevation: 0,
        titleTextStyle: SamuraiTextStyles.katanaSharp(fontSize: 20),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SamuraiColors.sanguineRed,
          foregroundColor: SamuraiColors.ashWhite,
          textStyle: SamuraiTextStyles.brushStroke(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: SamuraiColors.sanguineRed.withValues(alpha: 0.3),
        ),
      ),
      cardTheme: CardThemeData(
        color: SamuraiColors.ironGray,
        elevation: 8,
        shadowColor: SamuraiColors.midnightBlack.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: SamuraiColors.goldenKoi.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SamuraiColors.ironGray,
        selectedItemColor: SamuraiColors.goldenKoi,
        unselectedItemColor: SamuraiColors.ashWhite,
        type: BottomNavigationBarType.fixed,
        elevation: 15,
      ),
    );
  }
}

// Custom decorations for samurai-themed containers
class SamuraiDecorations {
  static BoxDecoration forgeContainer = BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        SamuraiColors.ironGray,
        Color(0xFF1a1e21),
      ],
    ),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: SamuraiColors.goldenKoi.withValues(alpha: 0.3),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: SamuraiColors.midnightBlack.withValues(alpha: 0.5),
        blurRadius: 8,
        offset: const Offset(2, 4),
      ),
    ],
  );

  static BoxDecoration templeNavigation = BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [SamuraiColors.ironGray, SamuraiColors.midnightBlack],
    ),
    boxShadow: [
      BoxShadow(
        color: SamuraiColors.sanguineRed.withValues(alpha: 0.3),
        blurRadius: 15,
        offset: const Offset(0, -5),
      )
    ],
    borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
  );

  static BoxDecoration scrollDecoration = BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [SamuraiColors.ashWhite, Color(0xFFF0F0E8)],
    ),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: SamuraiColors.goldenKoi, width: 2),
    boxShadow: [
      BoxShadow(
        color: SamuraiColors.midnightBlack.withValues(alpha: 0.3),
        blurRadius: 6,
        offset: const Offset(2, 3),
      ),
    ],
  );
}