import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeonColors {
  static const background = Color(0xFF070714);
  static const surface = Color(0xFF12122A);
  static const surfaceLight = Color(0xFF1A1A3A);
  static const mint = Color(0xFF00FFC8);
  static const purple = Color(0xFF7B2FFF);
  static const pink = Color(0xFFFF2D78);
  static const yellow = Color(0xFFFFD700);
  static const white = Color(0xFFFFFFFF);
  static const grey = Color(0xFF6B6B8A);
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: NeonColors.background,
      colorScheme: const ColorScheme.dark(
        primary: NeonColors.mint,
        secondary: NeonColors.purple,
        surface: NeonColors.surface,
      ),
      textTheme: GoogleFonts.orbitronTextTheme(base.textTheme).apply(
        bodyColor: NeonColors.white,
        displayColor: NeonColors.mint,
      ),
    );
  }
}
