import 'package:flutter/material.dart';

class AppTheme {
  // App Colors
  static const Color primaryBackground = Color(0xFF210F37);
  static const Color secondarySurface = Color(0xFF4F1C51);
  static const Color accentAction = Color(0xFFA55B4B);
  static const Color complementary = Color(0xFFDCA06D);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryBackground,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primaryBackground,
      onPrimary: Colors.white,
      secondary: secondarySurface,
      onSecondary: Colors.white,
      error: Colors.redAccent,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black87,
    ),
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBackground,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentAction,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: accentAction),
    ),
    // Card Theme
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: accentAction),
      ),
      labelStyle: const TextStyle(color: Colors.grey),
    ),
    // Text Theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: primaryBackground,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: primaryBackground,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: primaryBackground,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryBackground,
    scaffoldBackgroundColor: primaryBackground,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: accentAction,
      onPrimary: Colors.white,
      secondary: secondarySurface,
      onSecondary: Colors.white,
      error: Colors.redAccent,
      onError: Colors.white,
      surface: Color(0xFF2C1446), // Slightly lighter than primary for cards
      onSurface: Colors.white,
    ),
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBackground,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentAction,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: complementary),
    ),
    // Card Theme
    cardTheme: CardTheme(
      color: secondarySurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: secondarySurface.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: accentAction),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
    ),
    // Text Theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );
}
