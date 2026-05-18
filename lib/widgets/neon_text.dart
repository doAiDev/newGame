import 'package:flutter/material.dart';
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
    this.glowRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        letterSpacing: 3,
        shadows: [
          Shadow(color: color.withOpacity(0.8), blurRadius: glowRadius),
          Shadow(color: color.withOpacity(0.4), blurRadius: glowRadius * 2),
        ],
      ),
    );
  }
}
