import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color absoluteBlack = Color(0xFF1E2129); // Web Sidebar Blue-Black
  static const Color nearBlackCoal = Color(0xFF111827); // Dark Text
  static const Color offWhiteBackground = Color(0xFFF3F4F6); // Greyish background
  
  // Accents & Semantics
  static const Color amberAccent = Color(0xFFD97706); // Warning
  static const Color greenVerified = Color(0xFF059669); // Success
  static const Color redDanger = Color(0xFFDC2626); // Alert
  static const Color cobaltBlue = Color(0xFF2563EB); // Primary Action Blue
  static const Color borderGrey = Color(0xFFE5E7EB);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: offWhiteBackground,
      colorScheme: const ColorScheme.light(
        primary: absoluteBlack,
        secondary: amberAccent,
        surface: offWhiteBackground,
        onPrimary: Colors.white,
        onSecondary: nearBlackCoal,
        onSurface: nearBlackCoal,
        error: redDanger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: absoluteBlack,
        foregroundColor: offWhiteBackground,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: amberAccent,
          foregroundColor: nearBlackCoal,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: amberAccent,
        foregroundColor: nearBlackCoal,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: nearBlackCoal, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: nearBlackCoal, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: nearBlackCoal, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: nearBlackCoal, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: nearBlackCoal, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: nearBlackCoal, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: nearBlackCoal, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: nearBlackCoal, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: nearBlackCoal, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: nearBlackCoal),
        bodyMedium: TextStyle(color: nearBlackCoal),
        bodySmall: TextStyle(color: nearBlackCoal),
        labelLarge: TextStyle(color: nearBlackCoal, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: nearBlackCoal, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: nearBlackCoal, fontWeight: FontWeight.w500),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: nearBlackCoal, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: nearBlackCoal.withAlpha(76), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: amberAccent, width: 2),
        ),
      ),
    );
  }
}
