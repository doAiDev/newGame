import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class NeonText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final double glowRadius;

  const NeonText(
    this.text, {
    super.key,
    this.fontSize = 24,
    this.color = NeonColors.mint,
    this.glowRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.orbitron(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: 3,
        shadows: [
          Shadow(color: color, blurRadius: glowRadius),
          Shadow(color: color.withOpacity(0.4), blurRadius: glowRadius * 2.5),
        ],
      ),
    );
  }
}
