import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors matching the prototype
  static const Color graphite = Color(0xFF1E2A31);
  static const Color graphite2 = Color(0xFF2B3A43);
  static const Color graphite3 = Color(0xFF3A4B55);
  
  static const Color paper = Color(0xFFECEFEC);
  static const Color panel = Color(0xFFFFFFFF);

  static const Color ink = Color(0xFF1E2A31);
  static const Color ink2 = Color(0xFF55636B);
  static const Color ink3 = Color(0xFF7A868C);

  static const Color steel = Color(0xFF2F5D7C);
  static const Color steelBg = Color(0xFFE4EDF3);

  static const Color redDanger = Color(0xFFB8322A);
  static const Color redBg = Color(0xFFFBEAE8);

  static const Color amberAccent = Color(0xFFE0A21A);
  static const Color amberBg = Color(0xFFFCF2DA);

  static const Color greenVerified = Color(0xFF2F7A4A);
  static const Color greenBg = Color(0xFFE4F1E8);

  static const Color line = Color(0xFFD3D9D5);
  static const Color lineSoft = Color(0xFFE6EAE7);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: paper,
      colorScheme: const ColorScheme.light(
        primary: graphite,
        secondary: steel,
        surface: panel,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: ink,
        error: redDanger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: graphite,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: ink, fontFamily: 'Barlow'),
        bodyMedium: TextStyle(color: ink, fontFamily: 'Barlow'),
        titleLarge: TextStyle(color: ink, fontWeight: FontWeight.bold, fontFamily: 'Barlow Semi Condensed'),
      ),
    );
  }
}
