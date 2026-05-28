import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/transitions.dart';
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
  late AnimationController _entranceController;
  final List<_Star> _stars = [];

  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _buttonsFade;
  late Animation<Offset> _buttonsSlide;

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

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
      ),
    );
    _buttonsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
      ),
    );
    _buttonsSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    final random = Random();
    for (int i = 0; i < 80; i++) {
      _stars.add(_Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2 + 0.5,
        speed: random.nextDouble() * 0.3 + 0.1,
      ));
    }

    Future.microtask(() => _entranceController.forward());
  }

  @override
  void dispose() {
    _starController.dispose();
    _carController.dispose();
    _glowController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeonColors.background,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _starController,
            builder: (_, __) => CustomPaint(
              painter: _StarfieldPainter(_stars, _starController.value),
              size: Size.infinite,
            ),
          ),

          // Ambient glow top-left
          Positioned(
            top: -100,
            left: -80,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (_, __) => Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      NeonColors.purple.withOpacity(0.12 + _glowController.value * 0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Ambient glow bottom-right
          Positioned(
            bottom: 40,
            right: -70,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (_, __) => Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      NeonColors.mint.withOpacity(0.08 + (1 - _glowController.value) * 0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Road at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 180,
            child: CustomPaint(painter: _RoadPerspectivePainter()),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 56),

                // Title
                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _titleFade,
                    child: AnimatedBuilder(
                      animation: _glowController,
                      builder: (_, __) => Column(
                        children: [
                          NeonText(
                            'NEON',
                            fontSize: 52,
                            color: NeonColors.mint,
                            glowRadius: 18 + _glowController.value * 12,
                          ),
                          NeonText(
                            'DRIVE',
                            fontSize: 52,
                            color: NeonColors.purple,
                            glowRadius: 18 + (1 - _glowController.value) * 12,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'NIGHT CITY RACING',
                            style: TextStyle(
                              color: NeonColors.grey,
                              fontSize: 11,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Car preview
                AnimatedBuilder(
                  animation: _carController,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _carController.value * 8 - 4),
                    child: CustomPaint(
                      painter: _CarPreviewPainter(_carController.value),
                      size: const Size(110, 185),
                    ),
                  ),
                ),

                const Spacer(),

                // Buttons
                SlideTransition(
                  position: _buttonsSlide,
                  child: FadeTransition(
                    opacity: _buttonsFade,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: NeonButton(
                              label: 'PLAY',
                              icon: Icons.play_arrow_rounded,
                              color: NeonColors.mint,
                              fontSize: 18,
                              onTap: () => Navigator.push(
                                context,
                                NeonPageRoute(page: const GameScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: NeonButton(
                                  label: 'GARAGE',
                                  icon: Icons.directions_car_rounded,
                                  color: NeonColors.purple,
                                  fontSize: 12,
                                  onTap: () => Navigator.push(
                                    context,
                                    NeonPageRoute(page: const GarageScreen()),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: NeonButton(
                                  label: 'RANKS',
                                  icon: Icons.leaderboard_rounded,
                                  color: NeonColors.pink,
                                  fontSize: 12,
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                FadeTransition(
                  opacity: _buttonsFade,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: NeonColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: NeonColors.yellow.withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.monetization_on_rounded,
                            color: NeonColors.yellow, size: 18),
                        SizedBox(width: 6),
                        Text(
                          '3,400',
                          style: TextStyle(
                            color: NeonColors.yellow,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),
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
  final double y;
  final double size;
  final double speed;
  const _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
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
      final opacity = (sin(progress * 2 * pi + star.x * 10) * 0.3 + 0.7)
          .clamp(0.2, 1.0);
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
      Paint()..color = const Color(0xFF1A1A2E).withOpacity(0.6),
    );
    final edgePaint = Paint()
      ..color = const Color(0xFF7B2FFF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawLine(
        Offset(size.width * 0.3, 0), Offset(0, size.height), edgePaint);
    canvas.drawLine(
        Offset(size.width * 0.7, 0), Offset(size.width, size.height), edgePaint);
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
    final g = animValue * 0.4 + 0.6;

    final glowPaint = Paint()
      ..color = const Color(0xFF7B2FFF).withOpacity(0.3 * g)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8), glowPaint);

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
      ..color = const Color(0xFF00FFC8).withOpacity(g)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(bodyPath, outlinePaint);

    final hlPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(w * 0.25, h * 0.08), 6, hlPaint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.08), 6, hlPaint);

    final tlPaint = Paint()
      ..color = const Color(0xFFFF2D78).withOpacity(g)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.1, h * 0.92, w * 0.25, 8), tlPaint);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.65, h * 0.92, w * 0.25, 8), tlPaint);
  }

  @override
  bool shouldRepaint(_CarPreviewPainter old) => old.animValue != animValue;
}
