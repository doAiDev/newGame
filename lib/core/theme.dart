import 'package:flutter/material.dart';

class NeonColors {
  static const background = Color(0xFF0A0A1A);
  static const surface = Color(0xFF1A1A2E);
  static const surfaceLight = Color(0xFF16213E);
  static const mint = Color(0xFF00FFC8);
  static const purple = Color(0xFF7B2FFF);
  static const pink = Color(0xFFFF2D78);
  static const yellow = Color(0xFFFFD700);
  static const white = Color(0xFFFFFFFF);
  static const grey = Color(0xFF8888AA);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: NeonColors.background,
        colorScheme: const ColorScheme.dark(
          primary: NeonColors.mint,
          secondary: NeonColors.purple,
          surface: NeonColors.surface,
        ),
        fontFamily: 'monospace',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: NeonColors.mint,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
          titleLarge: TextStyle(
            color: NeonColors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          bodyMedium: TextStyle(
            color: NeonColors.grey,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      );
}
