import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_text.dart';
import 'game_screen.dart';
import 'garage_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _carController;
  late AnimationController _glowController;
  final List<_Star> _stars = [];

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _carController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    final random = Random();
    for (int i = 0; i < 60; i++) {
      _stars.add(_Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2 + 0.5,
        speed: random.nextDouble() * 0.3 + 0.1,
      ));
    }
  }

  @override
  void dispose() {
    _starController.dispose();
    _carController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeonColors.background,
      body: Stack(
        children: [
          // Animated starfield
          AnimatedBuilder(
            animation: _starController,
            builder: (_, __) => CustomPaint(
              painter: _StarfieldPainter(_stars, _starController.value),
              size: Size.infinite,
            ),
          ),

          // Road perspective at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: CustomPaint(painter: _RoadPerspectivePainter()),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Title with glow
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (_, __) => Column(
                    children: [
                      NeonText(
                        'NEON',
                        fontSize: 52,
                        color: NeonColors.mint,
                        glowRadius: 20 + _glowController.value * 15,
                      ),
                      NeonText(
                        'DRIVE',
                        fontSize: 52,
                        color: NeonColors.purple,
                        glowRadius: 20 + (1 - _glowController.value) * 15,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                const Text(
                  'NIGHT CITY RACING',
                  style: TextStyle(
                    color: NeonColors.grey,
                    fontSize: 12,
                    letterSpacing: 4,
                  ),
                ),

                const SizedBox(height: 50),

                // Animated car preview
                AnimatedBuilder(
                  animation: _carController,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _carController.value * 8 - 4),
                    child: CustomPaint(
                      painter: _CarPreviewPainter(_carController.value),
                      size: const Size(120, 200),
                    ),
                  ),
                ),

                const Spacer(),

                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: NeonButton(
                          label: 'PLAY',
                          icon: Icons.play_arrow,
                          color: NeonColors.mint,
                          fontSize: 18,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const GameScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: NeonButton(
                              label: 'GARAGE',
                              icon: Icons.directions_car,
                              color: NeonColors.purple,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const GarageScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: NeonButton(
                              label: 'RANKS',
                              icon: Icons.leaderboard,
                              color: NeonColors.pink,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Coin balance
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.monetization_on, color: NeonColors.yellow, size: 20),
                    SizedBox(width: 6),
                    Text(
                      '3,400',
                      style: TextStyle(
                        color: NeonColors.yellow,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Star {
  final double x;
  double y;
  final double size;
  final double speed;
  _Star({required this.x, required this.y, required this.size, required this.speed});
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double progress;
  _StarfieldPainter(this.stars, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in stars) {
      final y = (star.y + progress * star.speed) % 1.0;
      final opacity = (sin(progress * 2 * pi + star.x * 10) * 0.3 + 0.7).clamp(0.2, 1.0);
      paint.color = const Color(0xFFFFFFFF).withOpacity(opacity * 0.8);
      canvas.drawCircle(
        Offset(star.x * size.width, y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter old) => true;
}

class _RoadPerspectivePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.3, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.7, 0)
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFF1A1A2E).withOpacity(0.7),
    );

    // Neon road edges
    final edgePaint = Paint()
      ..color = const Color(0xFF7B2FFF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(0, size.height), edgePaint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width, size.height), edgePaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _CarPreviewPainter extends CustomPainter {
  final double animValue;
  _CarPreviewPainter(this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final glowIntensity = animValue * 0.4 + 0.6;

    // Glow
    final glowPaint = Paint()
      ..color = const Color(0xFF7B2FFF).withOpacity(0.3 * glowIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8), glowPaint);

    // Body
    final bodyPath = Path()
      ..moveTo(w * 0.15, h)
      ..lineTo(w * 0.05, h * 0.75)
      ..lineTo(w * 0.1, h * 0.25)
      ..lineTo(w * 0.3, h * 0.05)
      ..lineTo(w * 0.7, h * 0.05)
      ..lineTo(w * 0.9, h * 0.25)
      ..lineTo(w * 0.95, h * 0.75)
      ..lineTo(w * 0.85, h)
      ..close();
    canvas.drawPath(bodyPath, Paint()..color = const Color(0xFF0F0F2F));

    final outlinePaint = Paint()
      ..color = const Color(0xFF00FFC8).withOpacity(glowIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(bodyPath, outlinePaint);

    // Headlights
    final hlPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(w * 0.25, h * 0.08), 6, hlPaint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.08), 6, hlPaint);

    // Tail lights
    final tlPaint = Paint()
      ..color = const Color(0xFFFF2D78).withOpacity(glowIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.92, w * 0.25, 8), tlPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.65, h * 0.92, w * 0.25, 8), tlPaint);
  }

  @override
  bool shouldRepaint(_CarPreviewPainter old) => old.animValue != animValue;
}
