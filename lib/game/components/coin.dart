import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../../core/constants.dart';

class Coin extends PositionComponent with HasGameReference {
  double _pulseTimer = 0;

  Coin({required Vector2 position})
      : super(
          position: position,
          size: Vector2(20, 20),
          anchor: Anchor.center,
        );

  @override
  void update(double dt) {
    _pulseTimer += dt * 3;
    final gameSpeed = (game as dynamic).currentSpeed as double;
    y += gameSpeed * dt;
  }

  bool get isOffScreen => y > game.size.y + 20;

  @override
  void render(Canvas canvas) {
    final pulse = (sin(_pulseTimer) * 0.3 + 0.7);
    final r = size.x / 2;

    final glowPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.3 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(r, r), r * 1.5, glowPaint);

    final coinPaint = Paint()..color = const Color(0xFFFFD700).withValues(alpha: pulse);
    canvas.drawCircle(Offset(r, r), r, coinPaint);

    final innerPaint = Paint()..color = const Color(0xFFFFA500).withValues(alpha: pulse);
    canvas.drawCircle(Offset(r, r), r * 0.6, innerPaint);
  }
}

class CoinSpawner extends Component with HasGameReference {
  static final _random = Random();
  double _spawnTimer = 0;

  @override
  void update(double dt) {
    _spawnTimer += dt;
    if (_spawnTimer >= 2.0) {
      _spawnTimer = 0;
      _spawnRow();
    }
  }

  void _spawnRow() {
    final roadLeft = (game.size.x - GameConstants.roadWidth) / 2;
    final lane = _random.nextInt(GameConstants.laneCount);
    final x = roadLeft + GameConstants.laneWidth * lane + GameConstants.laneWidth / 2;
    final count = 3 + _random.nextInt(4);
    for (int i = 0; i < count; i++) {
      game.add(Coin(position: Vector2(x, -30.0 - i * 35)));
    }
  }
}
