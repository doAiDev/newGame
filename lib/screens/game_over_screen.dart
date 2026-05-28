import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_text.dart';

class GameOverScreen extends StatefulWidget {
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
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _statsController;
  late AnimationController _buttonsController;

  late Animation<double> _titleScale;
  late Animation<double> _titleFade;
  late Animation<double> _statsFade;
  late Animation<Offset> _statsSlide;
  late Animation<double> _buttonsFade;
  late Animation<Offset> _buttonsSlide;

  @override
  void initState() {
    super.initState();

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _buttonsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _titleScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.elasticOut),
    );
    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOut),
    );
    _statsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.easeOut),
    );
    _statsSlide = Tween<Offset>(
      begin: const Offset(0.12, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.easeOutCubic),
    );
    _buttonsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeOut),
    );
    _buttonsSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _buttonsController, curve: Curves.easeOutCubic),
    );

    _titleController.forward().then((_) {
      _statsController.forward().then((_) {
        _buttonsController.forward();
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _statsController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NeonColors.background.withOpacity(0.96),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _titleFade,
                  child: ScaleTransition(
                    scale: _titleScale,
                    child: NeonText(
                      'CRASH!',
                      fontSize: 48,
                      color: NeonColors.pink,
                      glowRadius: 28,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                SlideTransition(
                  position: _statsSlide,
                  child: FadeTransition(
                    opacity: _statsFade,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: NeonColors.surface,
                        border: Border.all(
                          color: NeonColors.purple.withOpacity(0.35),
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: NeonColors.purple.withOpacity(0.12),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _statRow('DISTANCE',
                              '${widget.distance.toStringAsFixed(2)} km',
                              NeonColors.mint),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Divider(
                              color: NeonColors.grey.withOpacity(0.15),
                              height: 1,
                            ),
                          ),
                          _statRow('COINS', '+${widget.coins}', NeonColors.yellow),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Divider(
                              color: NeonColors.grey.withOpacity(0.15),
                              height: 1,
                            ),
                          ),
                          _statRow('BEST', '5.10 km', NeonColors.purple),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                SlideTransition(
                  position: _buttonsSlide,
                  child: FadeTransition(
                    opacity: _buttonsFade,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: NeonButton(
                            label: 'REVIVE',
                            icon: Icons.favorite_rounded,
                            color: NeonColors.mint,
                            fontSize: 15,
                            onTap: widget.onRevive,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: NeonButton(
                                label: 'HOME',
                                icon: Icons.home_rounded,
                                color: NeonColors.grey,
                                onTap: widget.onHome,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: NeonButton(
                                label: 'RETRY',
                                icon: Icons.refresh_rounded,
                                color: NeonColors.purple,
                                onTap: widget.onRestart,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
        Text(
          label,
          style: const TextStyle(
            color: NeonColors.grey,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
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
    );
  }
}
