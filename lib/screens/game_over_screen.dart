import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_text.dart';

class GameOverScreen extends StatelessWidget {
  final int coins;
  final double distance;
  final VoidCallback onRevive;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const GameOverScreen({
    super.key,
    required this.coins,
    required this.distance,
    required this.onRevive,
    required this.onRestart,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NeonColors.background.withOpacity(0.92),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NeonText('CRASH!', fontSize: 48, color: NeonColors.pink, glowRadius: 30),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: NeonColors.surface,
                    border: Border.all(color: NeonColors.purple.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      _statRow('DISTANCE', '${distance.toStringAsFixed(2)} km', NeonColors.mint),
                      const SizedBox(height: 12),
                      _statRow('COINS', '+$coins', NeonColors.yellow),
                      const SizedBox(height: 12),
                      _statRow('BEST', '5.10 km', NeonColors.purple),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: NeonButton(
                    label: 'REVIVE',
                    icon: Icons.favorite,
                    color: NeonColors.mint,
                    fontSize: 15,
                    onTap: onRevive,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: NeonButton(
                        label: 'HOME',
                        icon: Icons.home,
                        color: NeonColors.grey,
                        onTap: onHome,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeonButton(
                        label: 'RETRY',
                        icon: Icons.refresh,
                        color: NeonColors.purple,
                        onTap: onRestart,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: NeonColors.grey, letterSpacing: 2, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1,
            shadows: [Shadow(color: color, blurRadius: 8)],
          ),
        ),
      ],
    ),;
  }
}
