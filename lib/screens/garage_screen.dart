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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: NeonColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: NeonColors.mint.withOpacity(0.3),
                        ),
                      ),
                      child: const Icon(Icons.arrow_back_ios_rounded,
                          color: NeonColors.mint, size: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const NeonText('GARAGE', fontSize: 20),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: NeonColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: NeonColors.yellow.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on_rounded,
                            color: NeonColors.yellow, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$_coins',
                          style: const TextStyle(
                            color: NeonColors.yellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Car display
            Expanded(
              flex: 3,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow
                  AnimatedBuilder(
                    animation: _glowController,
                    builder: (_, __) => AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: car.glowColor.withOpacity(
                                0.18 + _glowController.value * 0.1),
                            blurRadius: 90,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Car switcher
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          color: _selectedIndex > 0
                              ? NeonColors.mint
                              : NeonColors.grey.withOpacity(0.25),
                          size: 42,
                        ),
                        onPressed: _selectedIndex > 0
                            ? () => setState(() => _selectedIndex--)
                            : null,
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.82, end: 1.0)
                                .animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutBack,
                            )),
                            child: child,
                          ),
                        ),
                        child: AnimatedBuilder(
                          key: ValueKey(_selectedIndex),
                          animation: _glowController,
                          builder: (_, __) => CustomPaint(
                            painter:
                                _GarageCarPainter(car, _glowController.value),
                            size: const Size(130, 220),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.chevron_right_rounded,
                          color: _selectedIndex < _cars.length - 1
                              ? NeonColors.mint
                              : NeonColors.grey.withOpacity(0.25),
                          size: 42,
                        ),
                        onPressed: _selectedIndex < _cars.length - 1
                            ? () => setState(() => _selectedIndex++)
                            : null,
                      ),
                    ],
                  ),

                  // Car name
                  Positioned(
                    bottom: 20,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: NeonText(
                        car.name,
                        key: ValueKey(car.name),
                        fontSize: 18,
                        color: car.color,
                      ),
                    ),
                  ),

                  // Page dots
                  Positioned(
                    bottom: 2,
                    child: Row(
                      children: List.generate(
                        _cars.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == _selectedIndex ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _selectedIndex
                                ? car.color
                                : NeonColors.grey.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: i == _selectedIndex
                                ? [
                                    BoxShadow(
                                      color: car.color.withOpacity(0.5),
                                      blurRadius: 6,
                                    )
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Animated stat bars
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: Column(
                  key: ValueKey(_selectedIndex),
                  children: [
                    _statBar('SPEED', car.speed, NeonColors.mint),
                    const SizedBox(height: 12),
                    _statBar('HANDLING', car.handling, NeonColors.purple),
                    const SizedBox(height: 12),
                    _statBar('ACCEL', car.acceleration, NeonColors.pink),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Action button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  key: ValueKey('${_selectedIndex}_${car.unlocked}'),
                  width: double.infinity,
                  child: car.unlocked
                      ? NeonButton(
                          label: 'SELECT',
                          icon: Icons.check_circle_rounded,
                          color: NeonColors.mint,
                          onTap: () => Navigator.pop(context),
                        )
                      : NeonButton(
                          label: '${car.price} COINS',
                          icon: Icons.monetization_on_rounded,
                          color: _coins >= car.price
                              ? NeonColors.purple
                              : NeonColors.grey,
                          enabled: _coins >= car.price,
                          onTap: () => setState(() => car.unlocked = true),
                        ),
                ),
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
          width: 82,
          child: Text(
            label,
            style: const TextStyle(
              color: NeonColors.grey,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: NeonColors.surface,
              borderRadius: BorderRadius.circular(3),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: v,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.5), color],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.55),
                        blurRadius: 6,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text(
            '${(value * 100).toInt()}',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
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
    final g = animValue * 0.4 + 0.6;

    final glowPaint = Paint()
      ..color = car.glowColor.withOpacity(0.25 * g)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
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
      ..color = car.color.withOpacity(g)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(bodyPath, outlinePaint);

    canvas.drawRect(
      Rect.fromLTWH(w * 0.2, h * 0.15, w * 0.6, h * 0.22),
      Paint()..color = car.color.withOpacity(0.15),
    );

    final hlPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(w * 0.25, h * 0.07), 6, hlPaint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.07), 6, hlPaint);

    final tlPaint = Paint()
      ..color = const Color(0xFFFF2D78).withOpacity(g)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.1, h * 0.92, w * 0.25, 8), tlPaint);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.65, h * 0.92, w * 0.25, 8), tlPaint);

    if (!car.unlocked) {
      canvas.drawPath(
          bodyPath, Paint()..color = Colors.black.withOpacity(0.65));
      final tp = TextPainter(
        text: const TextSpan(
          text: '🔒',
          style: TextStyle(fontSize: 30),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas,
          Offset(w / 2 - tp.width / 2, h / 2 - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_GarageCarPainter old) => old.animValue != animValue;
}
