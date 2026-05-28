import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class NeonButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final double fontSize;
  final bool enabled;
  final VoidCallback onTap;

  const NeonButton({
    super.key,
    required this.label,
    this.icon,
    this.color = NeonColors.purple,
    this.fontSize = 14,
    this.enabled = true,
    required this.onTap,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 0.22, end: 0.55).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _effectiveColor =>
      widget.enabled ? widget.color : NeonColors.grey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled
          ? (_) {
              _controller.forward();
              HapticFeedback.lightImpact();
            }
          : null,
      onTapUp: widget.enabled
          ? (_) {
              _controller.reverse();
              widget.onTap();
            }
          : null,
      onTapCancel: widget.enabled ? () => _controller.reverse() : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: _effectiveColor.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _effectiveColor.withOpacity(widget.enabled ? 0.85 : 0.35),
                width: 1.5,
              ),
              boxShadow: widget.enabled
                  ? [
                      BoxShadow(
                        color: _effectiveColor.withOpacity(_glow.value),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: child,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[{
              'icon': widget.icon,
            }].map((_) => Row(
              children: [
                Icon(widget.icon, color: _effectiveColor, size: widget.fontSize + 4),
                const SizedBox(width: 8),
              ],
            )).first,
            Text(
              widget.label,
              style: GoogleFonts.orbitron(
                color: _effectiveColor,
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                shadows: widget.enabled
                    ? [Shadow(color: _effectiveColor, blurRadius: 8)]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
