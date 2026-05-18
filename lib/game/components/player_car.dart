import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../../core/constants.dart';

class PlayerCar extends PositionComponent with DragCallbacks {
  static const double _glowRadius = 16.0;
  final Color bodyColor;
  final Color glowColor;

  double _targetX = 0;
  bool isDead = false;

  PlayerCar({
    this.bodyColor = const Color(0xFF00FFC8),
    this.glowColor = const Color(0xFF7B2FFF),
  }) : super(
          size: Vector2(GameConstants.playerCarWidth, GameConstants.playerCarHeight),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    _targetX = x;
  }

  @override
  void update(double dt) {
    // Smooth horizontal movement
    x += (_targetX - x) * 10 * dt;
  }

  void moveLeft(double roadLeft) {
    _targetX = (x - GameConstants.laneWidth).clamp(
      roadLeft + GameConstants.playerCarWidth / 2,
      roadLeft + GameConstants.roadWidth - GameConstants.playerCarWidth / 2,
    );
  }

  void moveRight(double roadLeft) {
    _targetX = (x + GameConstants.laneWidth).clamp(
      roadLeft + GameConstants.playerCarWidth / 2,
      roadLeft + GameConstants.roadWidth - GameConstants.playerCarWidth / 2,
    );
  }

  @override
  void render(Canvas canvas) {
    if (isDead) return;
    _drawCar(canvas);
  }

  void _drawCar(Canvas canvas) {
    final w = size.x;
    final h = size.y;

    // Glow underneath car
    final glowPaint = Paint()
      ..color = glowColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowRadius);
    canvas.drawRect(Rect.fromLTWH(2, h * 0.1, w - 4, h * 0.8), glowPaint);

    // Car body
    final bodyPaint = Paint()..color = const Color(0xFF0F0F1F);
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
    canvas.drawPath(bodyPath, bodyPaint);

    // Neon outline
    final outlinePaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(bodyPath, outlinePaint);

    // Windshield
    final glassPaint = Paint()..color = bodyColor.withOpacity(0.2);
    canvas.drawRect(Rect.fromLTWH(w * 0.2, h * 0.15, w * 0.6, h * 0.22), glassPaint);

    // Headlights
    final headlightPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(w * 0.25, h * 0.06), 5, headlightPaint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.06), 5, headlightPaint);

    // Tail lights
    final tailPaint = Paint()
      ..color = const Color(0xFFFF2D78)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRect(Rect.fromLTWH(w * 0.1, h * 0.9, w * 0.25, 8), tailPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.65, h * 0.9, w * 0.25, 8), tailPaint);

    // Speed lines under car
    final speedPaint = Paint()
      ..color = glowColor.withOpacity(0.5)
      ..strokeWidth = 1;
    for (int i = 0; i < 3; i++) {
      final lineX = w * 0.2 + i * (w * 0.3);
      canvas.drawLine(Offset(lineX, h), Offset(lineX, h + 12), speedPaint);
    }
  }
}
