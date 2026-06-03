// lib/core/theme/app_theme.dart
//
// APP THEME
// ==========
// Defines the visual style of the entire app: colors, fonts, spacing.
// Having this in one place means if you want to change the look,
// you change it here and it updates everywhere.
//
// DESIGN NOTES:
// - High contrast for outdoor/sunlight readability
// - Large text for use with gloves and dirty hands
// - Construction-inspired color palette (warm, earthy, professional)

import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand Colors ──
  static const Color primaryColor = Color(0xFFD4762C);      // Construction orange
  static const Color secondaryColor = Color(0xFF2C5F8A);    // Steel blue
  static const Color accentColor = Color(0xFF4CAF50);       // Green (complete/success)
  static const Color errorColor = Color(0xFFD32F2F);        // Red (flagged/errors)
  static const Color warningColor = Color(0xFFFFA726);      // Amber (warnings)

  // ── Neutral Colors ──
  static const Color backgroundColor = Color(0xFFF5F5F5);   // Light gray
  static const Color surfaceColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121);       // Near-black
  static const Color textSecondary = Color(0xFF757575);     // Medium gray
  static const Color dividerColor = Color(0xFFBDBDBD);      // Light gray

  // ── Role Colors ──
  // Each role gets a distinct color for badges and UI elements
  static const Map<String, Color> roleColors = {
    'measurer': Color(0xFF2196F3),           // Blue
    'materialHandler': Color(0xFF9C27B0),    // Purple
    'cutter': Color(0xFFFF9800),             // Orange
    'installerAssembler': Color(0xFF4CAF50), // Green
    'moneyHandler': Color(0xFF795548),       // Brown
    'projectLeader': Color(0xFF607D8B),      // Blue-gray
  };

  // ── Priority Colors ──
  static const Map<String, Color> priorityColors = {
    'low': Color(0xFF8BC34A),       // Light green
    'medium': Color(0xFFFFC107),    // Yellow
    'high': Color(0xFFFF9800),      // Orange
    'critical': Color(0xFFF44336),  // Red
  };

  // ── Light Theme ──
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),

      // Scaffold (screen background)
      scaffoldBackgroundColor: backgroundColor,

      // App bar
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Buttons — large for easy tapping with gloves
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),  // Minimum 48px tap target
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: surfaceColor,
      ),

      // Cards
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // Bottom navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),

      // Typography — slightly larger than default for outdoor readability
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textPrimary),
        bodySmall: TextStyle(fontSize: 12, color: textSecondary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
      ),
    );
  }

  // ── Dark Theme (for low-light conditions) ──
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }
}
