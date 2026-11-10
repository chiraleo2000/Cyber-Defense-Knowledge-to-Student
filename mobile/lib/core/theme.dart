import 'package:flutter/material.dart';

/// Thai-first, offline-friendly palette — no Google Fonts dependency.
class AppTheme {
  static const Color ink = Color(0xFF1A1F2E);
  static const Color inkSoft = Color(0xFF4A5568);
  static const Color inkFaint = Color(0xFF718096);
  static const Color surface = Color(0xFFFFFFF8);
  static const Color surface2 = Color(0xFFF3F0EA);
  static const Color line = Color(0xFFD9D2C5);
  static const Color accent = Color(0xFF2C5282);
  static const Color danger = Color(0xFFC53030);
  static const Color warn = Color(0xFFB7791F);
  static const Color safe = Color(0xFF1F7A4C);
  static const Color ribbonBg = Color(0xFFFFF5F5);
  static const Color ribbonLine = Color(0xFFFECACA);

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
        primary: accent,
        error: danger,
        surface: surface,
      ),
      scaffoldBackgroundColor: surface2,
      fontFamily: 'Tahoma',
      fontFamilyFallback: const [
        'Leelawadee UI',
        'Cordia New',
        'Noto Sans Thai',
        'sans-serif',
      ],
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Tahoma',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: const BorderSide(color: line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: ink,
        displayColor: ink,
      ),
    );
  }
}
