import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../core/theme.dart';
import '../game/neon_drive_game.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_text.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late NeonDriveGame _game;
  bool _gameOver = false;
  int _coins = 0;
  double _distance = 0;
  int _lives = 3;

  @override
  void initState() {
    super.initState();
    _game = NeonDriveGame(
      onGameOver: _handleGameOver,
      onStatsUpdate: (coins, distance) {
        if (mounted) {
          setState(() {
            _coins = coins;
            _distance = distance;
            _lives = _game.lives;
          });
        }
      },
    );
  }

  void _handleGameOver() {
    if (mounted) setState(() => _gameOver = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeonColors.background,
      body: Stack(
        children: [
          GameWidget(game: _game),
          if (!_gameOver)
            SafeArea(
              child: Column(
                children: [
                  _buildHUD(),
                  const Spacer(),
                  _buildControls(),
                ],
              ),
            ),
          if (_gameOver)
            GameOverScreen(
              coins: _coins,
              distance: _distance,
              onRevive: _handleRevive,
              onRestart: _handleRestart,
              onHome: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Row(
            children: List.generate(3, (i) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.favorite,
                color: i < _lives ? NeonColors.pink : NeonColors.grey.withOpacity(0.3),
                size: 20,
                shadows: i < _lives
                    ? [const Shadow(color: NeonColors.pink, blurRadius: 8)]
                    : null,
              ),
            )),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.monetization_on, color: NeonColors.yellow, size: 18),
              const SizedBox(width: 4),
              Text(
                '$_coins',
                style: const TextStyle(
                  color: NeonColors.yellow,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Text(
            '${_distance.toStringAsFixed(1)} km',
            style: const TextStyle(
              color: NeonColors.mint,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              _game.pause();
              showDialog(
                context: context,
                builder: (_) => _PauseDialog(
                  onResume: () {
                    Navigator.pop(context);
                    _game.resume();
                  },
                  onHome: () => Navigator.popUntil(context, (r) => r.isFirst),
                ),
              );
            },
            child: const Icon(Icons.pause, color: NeonColors.grey, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _game.moveLeft,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: NeonColors.surface.withOpacity(0.7),
                  border: Border.all(color: NeonColors.purple.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back_ios, color: NeonColors.purple, size: 28),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _game.moveRight,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: NeonColors.surface.withOpacity(0.7),
                  border: Border.all(color: NeonColors.purple.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_forward_ios, color: NeonColors.purple, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRevive() {
    setState(() => _gameOver = false);
    _game.revive();
  }

  void _handleRestart() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
  }
}

class _PauseDialog extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onHome;
  const _PauseDialog({required this.onResume, required this.onHome});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: NeonColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: NeonColors.mint, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const NeonText('PAUSED', fontSize: 28),
            const SizedBox(height: 32),
            NeonButton(label: 'RESUME', icon: Icons.play_arrow, onTap: onResume),
            const SizedBox(height: 12),
            NeonButton(label: 'HOME', icon: Icons.home, color: NeonColors.grey, onTap: onHome),
          ],
        ),
      ),
    );
  }
}
