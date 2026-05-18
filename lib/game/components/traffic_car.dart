import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../../core/constants.dart';

class TrafficCar extends PositionComponent with HasGameReference {
  static final _random = Random();
  static final _colors = [
    const Color(0xFFFF4444),
    const Color(0xFF4444FF),
    const Color(0xFF44FF44),
    const Color(0xFFFF8800),
    const Color(0xFFFF44FF),
    const Color(0xFFFFFF44),
  ];

  final Color accentColor;
  final double relativeSpeed;

  TrafficCar({
    required Vector2 position,
    double? speed,
  })  : accentColor = _colors[_random.nextInt(_colors.length)],
        relativeSpeed = speed ?? (50 + _random.nextDouble() * 80),
        super(
          position: position,
          size: Vector2(GameConstants.trafficCarWidth, GameConstants.trafficCarHeight),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    final gameSpeed = (game as dynamic).currentSpeed as double;
    y += (gameSpeed - relativeSpeed) * dt;
  }

  bool get isOffScreen => y > (game.size.y + size.y);
  bool get isAboveScreen => y < -size.y * 2;

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    final bodyPaint = Paint()..color = const Color(0xFF151525);
    final bodyPath = Path()
      ..moveTo(w * 0.1, h)
      ..lineTo(w * 0.05, h * 0.7)
      ..lineTo(w * 0.1, h * 0.2)
      ..lineTo(w * 0.3, h * 0.02)
      ..lineTo(w * 0.7, h * 0.02)
      ..lineTo(w * 0.9, h * 0.2)
      ..lineTo(w * 0.95, h * 0.7)
      ..lineTo(w * 0.9, h)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    final outlinePaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(bodyPath, outlinePaint);

    final headlightPaint = Paint()
      ..color = const Color(0xFFFFEEAA)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(w * 0.25, h * 0.96), 4, headlightPaint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.96), 4, headlightPaint);

    final brakePaint = Paint()
      ..color = const Color(0xFFFF2D78)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawRect(Rect.fromLTWH(w * 0.1, 0, w * 0.2, 6), brakePaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.7, 0, w * 0.2, 6), brakePaint);
  }
}

class TrafficSpawner extends Component with HasGameReference {
  static final _random = Random();
  double _spawnTimer = 0;
  double _spawnInterval = 1.5;

  @override
  void update(double dt) {
    _spawnTimer += dt;
    final gameSpeed = (game as dynamic).currentSpeed as double;
    _spawnInterval = (3.0 - (gameSpeed / 500)).clamp(0.4, 2.0);

    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnCar();
    }
  }

  void _spawnCar() {
    final roadLeft = (game.size.x - GameConstants.roadWidth) / 2;
    final lane = _random.nextInt(GameConstants.laneCount);
    final x = roadLeft + GameConstants.laneWidth * lane + GameConstants.laneWidth / 2;
    final car = TrafficCar(
      position: Vector2(x, -GameConstants.trafficCarHeight),
    );
    game.add(car);
  }
}
