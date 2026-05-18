import 'dart:ui';
import 'package:flame/components.dart';

class Road extends PositionComponent with HasGameReference {
  static const double _lineHeight = 40.0;
  static const double _lineGap = 30.0;
  static const double _lineWidth = 3.0;
  static const int _laneCount = 4;

  double _scrollOffset = 0;

  @override
  Future<void> onLoad() async {
    size = game.size;
  }

  @override
  void update(double dt) {
    final speed = (game as dynamic).currentSpeed as double;
    _scrollOffset = (_scrollOffset + speed * dt) % (_lineHeight + _lineGap);
  }

  @override
  void render(Canvas canvas) {
    final screenSize = game.size;
    final roadLeft = (screenSize.x - 320) / 2;
    final roadRight = roadLeft + 320;

    final roadPaint = Paint()..color = const Color(0xFF1A1A2E);
    canvas.drawRect(
      Rect.fromLTRB(roadLeft, 0, roadRight, screenSize.y),
      roadPaint,
    );

    final edgePaint = Paint()
      ..color = const Color(0xFF7B2FFF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawLine(Offset(roadLeft, 0), Offset(roadLeft, screenSize.y), edgePaint);
    canvas.drawLine(Offset(roadRight, 0), Offset(roadRight, screenSize.y), edgePaint);

    final lanePaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.4)
      ..strokeWidth = _lineWidth;

    for (int lane = 1; lane < _laneCount; lane++) {
      final x = roadLeft + (320 / _laneCount) * lane;
      double y = -_scrollOffset;
      while (y < screenSize.y) {
        canvas.drawLine(Offset(x, y), Offset(x, y + _lineHeight), lanePaint);
        y += _lineHeight + _lineGap;
      }
    }

    _drawCitySkyline(canvas, screenSize, roadLeft, roadRight);
  }

  void _drawCitySkyline(Canvas canvas, dynamic size, double roadLeft, double roadRight) {
    final skyPaint = Paint()..color = const Color(0xFF0D0D2B);
    final buildingHeights = [60.0, 90.0, 50.0, 110.0, 70.0, 85.0, 45.0, 100.0];
    final buildingWidth = roadLeft / buildingHeights.length;

    for (int i = 0; i < buildingHeights.length; i++) {
      final h = buildingHeights[i];
      canvas.drawRect(
        Rect.fromLTWH(i * buildingWidth, 0, buildingWidth - 2, h),
        skyPaint,
      );
    }

    for (int i = 0; i < buildingHeights.length; i++) {
      final h = buildingHeights[buildingHeights.length - 1 - i];
      canvas.drawRect(
        Rect.fromLTWH(roadRight + i * buildingWidth, 0, buildingWidth - 2, h),
        skyPaint,
      );
    }
  }
}
