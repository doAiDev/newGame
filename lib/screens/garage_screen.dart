import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_text.dart';

class CarModel {
  final String name;
  final int price;
  final double speed;
  final double handling;
  final double acceleration;
  final Color color;
  final Color glowColor;
  bool unlocked;

  CarModel({
    required this.name,
    required this.price,
    required this.speed,
    required this.handling,
    required this.acceleration,
    required this.color,
    required this.glowColor,
    this.unlocked = false,
  });
}

class GarageScreen extends StatefulWidget {
  const GarageScreen({super.key});

  @override
  State<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  int _selectedIndex = 0;
  final int _coins = 3400;

  final List<CarModel> _cars = [
    CarModel(
      name: 'SPECTER',
      price: 0,
      speed: 0.6,
      handling: 0.7,
      acceleration: 0.65,
      color: const Color(0xFF00FFC8),
      glowColor: const Color(0xFF7B2FFF),
      unlocked: true,
    ),
    CarModel(
      name: 'PHANTOM X99',
      price: 5000,
      speed: 0.8,
      handling: 0.6,
      acceleration: 0.75,
      color: const Color(0xFFFF2D78),
      glowColor: const Color(0xFFFF2D78),
    ),
    CarModel(
      name: 'NEON GHOST',
      price: 10000,
      speed: 0.95,
      handling: 0.85,
      acceleration: 0.9,
      color: const Color(0xFF7B2FFF),
      glowColor: const Color(0xFF00FFC8),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final car = _cars[_selectedIndex];
    return Scaffold(
      backgroundColor: NeonColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, color: NeonColors.mint),
                  ),
                  const SizedBox(width: 12),
                  const NeonText('GARAGE', fontSize: 22),
                  const Spacer(),
                  const Icon(Icons.monetization_on, color: NeonColors.yellow, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '$_coins',
                    style: const TextStyle(
                      color: NeonColors.yellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: NeonColors.surface, height: 1),

            // Car display
            Expanded(
              flex: 3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background glow
                  AnimatedBuilder(
                    animation: _glowController,
                    builder: (_, __) => Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: car.glowColor.withOpacity(0.15 + _glowController.value * 0.1),
                            blurRadius: 80,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Car with nav arrows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: NeonColors.mint, size: 36),
                        onPressed: _selectedIndex > 0
                            ? () => setState(() => _selectedIndex--)
                            : null,
                      ),
                      AnimatedBuilder(
                        animation: _glowController,
                        builder: (_, __) => CustomPaint(
                          painter: _GarageCarPainter(car, _glowController.value),
                          size: const Size(130, 220),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: NeonColors.mint, size: 36),
                        onPressed: _selectedIndex < _cars.length - 1
                            ? () => setState(() => _selectedIndex++)
                            : null,
                      ),
                    ],
                  ),

                  // Car name
                  Positioned(
                    bottom: 8,
                    child: NeonText(car.name, fontSize: 18, color: car.color),
                  ),
                ],
              ),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  _statBar('SPEED', car.speed, NeonColors.mint),
                  const SizedBox(height: 10),
                  _statBar('HANDLING', car.handling, NeonColors.purple),
                  const SizedBox(height: 10),
                  _statBar('ACCEL', car.acceleration, NeonColors.pink),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: car.unlocked
                  ? SizedBox(
                      width: double.infinity,
                      child: NeonButton(
                        label: 'SELECTED',
                        icon: Icons.check_circle,
                        color: NeonColors.mint,
                        onTap: () => Navigator.pop(context),
                      ),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: NeonButton(
                            label: '  WATCH AD TO UNLOCK',
                            icon: Icons.play_circle_fill,
                            color: NeonColors.yellow,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: NeonButton(
                            label: '${car.price} COINS',
                            icon: Icons.monetization_on,
                            color: _coins >= car.price ? NeonColors.purple : NeonColors.grey,
                            onTap: _coins >= car.price
                                ? () => setState(() => car.unlocked = true)
                                : () {},
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _statBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(color: NeonColors.grey, fontSize: 12, letterSpacing: 2)),
        ),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: NeonColors.surface,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withOpacity(0.6), color]),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GarageCarPainter extends CustomPainter {
  final CarModel car;
  final double animValue;
  _GarageCarPainter(this.car, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final glow = animValue * 0.4 + 0.6;

    final glowPaint = Paint()
      ..color = car.glowColor.withOpacity(0.25 * glow)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8), glowPaint);

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
      ..color = car.color.withOpacity(glow)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(bodyPath, outlinePaint);

    // Windshield
    canvas.drawRect(
      Rect.fromLTWH(w * 0.2, h * 0.15, w * 0.6, h * 0.22),
      Paint()..color = car.color.withOpacity(0.15),
    );

    // Headlights
    final hlPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(w * 0.25, h * 0.07), 6, hlPaint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.07), 6, hlPaint);

    // Tail lights
    final tlPaint = Paint()
      ..color = const Color(0xFFFF2D78).withOpacity(glow)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.92, w * 0.25, 8), tlPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.65, h * 0.92, w * 0.25, 8), tlPaint);

    if (!car.unlocked) {
      final lockPaint = Paint()..color = Colors.black.withOpacity(0.6);
      canvas.drawPath(bodyPath, lockPaint);
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '🔒',
          style: TextStyle(fontSize: 32),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(w / 2 - textPainter.width / 2, h / 2 - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_GarageCarPainter old) => old.animValue != animValue;
}
