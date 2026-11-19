import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Core Palette ──────────────────────────────────────────────
  static const Color background = Color(0xFF0A0E21);
  static const Color surface = Color(0xFF1D1E33);
  static const Color surfaceLight = Color(0xFF2A2D45);
  static const Color accent = Color(0xFF00E5FF);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentOrange = Color(0xFFFF9100);
  static const Color accentRed = Color(0xFFFF1744);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color cardBorder = Color(0xFF2E3148);

  // ── AQI Level Colors ─────────────────────────────────────────
  static const Color aqiGood = Color(0xFF4CAF50);
  static const Color aqiModerate = Color(0xFFFFEB3B);
  static const Color aqiUnhealthySensitive = Color(0xFFFF9800);
  static const Color aqiUnhealthy = Color(0xFFFF5722);
  static const Color aqiVeryUnhealthy = Color(0xFF9C27B0);
  static const Color aqiHazardous = Color(0xFF880E4F);

  // ── Gradients ─────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1D1E33), Color(0xFF252840)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Theme Data ────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        primaryColor: accent,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accentGreen,
          surface: surface,
          error: accentRed,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: cardBorder, width: 1),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: accent,
          unselectedItemColor: textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
          headlineMedium: TextStyle(
            color: textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
          labelLarge: TextStyle(
            color: accent,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
