import 'package:flutter/material.dart';

class AppTheme {
  // --- Imperial Emerald & Champagne Gold Palette ---
  static const Color emeraldDeep = Color(0xFF022C22); // Deepest luxury emerald
  static const Color emeraldDark = Color(0xFF064E3B);
  static const Color emeraldPrimary = Color(0xFF065F46); // Primary rich emerald
  static const Color emeraldAccent = Color(0xFF0D9488); // Teal-emerald bright
  static const Color emeraldLight = Color(0xFF10B981); // Bright safe mint
  static const Color emeraldSurface = Color(0xFFD1FAE5);

  // Luxury Gold & Accents
  static const Color goldBright = Color(0xFFFBBF24); // Champagne Gold
  static const Color goldAccent = Color(0xFFF59E0B); // Royal Gold
  static const Color goldDeep = Color(0xFFD97706); // Dark Gold / Bronze
  static const Color redCoral = Color(0xFFEF4444); // Warning / Expense Red
  static const Color redCoralSoft = Color(0xFFF87171);
  static const Color greenSafe = Color(0xFF10B981); // Safe Income Green

  // Obsidian Dark Theme Surfaces
  static const Color bgDark = Color(0xFF080E13); // Velvet Obsidian
  static const Color cardDark = Color(0xFF111A22); // Deep navy-slate card
  static const Color cardDarkElevated = Color(0xFF182430);
  static const Color borderDark = Color(0xFF1E2D3A);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textMutedDark = Color(0xFF94A3B8);

  // Pearl Light Theme Surfaces
  static const Color bgLight = Color(0xFFF5F7FA); // Soft pearl canvas
  static const Color cardLight = Colors.white;
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  static const String fontFamily = 'Cairo';

  // --- Gradient Presets ---
  static const LinearGradient emeraldCardGradient = LinearGradient(
    colors: [
      Color(0xFF064E3B),
      Color(0xFF065F46),
      Color(0xFF022C22),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldAccentGradient = LinearGradient(
    colors: [
      Color(0xFFFBBF24),
      Color(0xFFF59E0B),
      Color(0xFFD97706),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redExpenseGradient = LinearGradient(
    colors: [
      Color(0xFFEF4444),
      Color(0xFFDC2626),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: Brightness.light,
      primaryColor: emeraldPrimary,
      scaffoldBackgroundColor: bgLight,
      colorScheme: const ColorScheme.light(
        primary: emeraldPrimary,
        secondary: goldAccent,
        error: redCoral,
        surface: cardLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgLight,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: emeraldDark),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: emeraldDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: emeraldPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: emeraldPrimary.withAlpha(80),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: emeraldPrimary, width: 2),
        ),
      ),
    );
  }

  // Dark Theme (Obsidian Velvet)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: Brightness.dark,
      primaryColor: emeraldAccent,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: emeraldAccent,
        secondary: goldAccent,
        error: redCoral,
        surface: cardDark,
        onPrimary: emeraldDeep,
        onSecondary: Colors.black,
        onSurface: textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: goldBright),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: textLight,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: emeraldAccent,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: emeraldAccent.withAlpha(100),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDarkElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: goldBright, width: 2),
        ),
      ),
    );
  }
}
