import 'dart:ui';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'obstacle.dart';


class CrateProp extends GroundProp {
  final double size;

  @override
  final double width;
  @override
  final double height;

  CrateProp({
    required double x,
    required this.size,
    required this.width,
    required this.height,
    double speed = 120,
  }) : super(x, speed);

  @override
  PropCollisionType get collisionType =>
      PropCollisionType.solid;

  // CrateProp({
  //   required double x,
  //   required this.size,
  //   double speed = 120, // default scroll speed
  // }) : super(x, speed);


  @override
  void render(Canvas canvas, double Function(double) getTerrainY) {
    final groundY = getTerrainY(x);

    // =====================================================
    // BIGGER CRATE
    // =====================================================

    final crateWidth = size * 1.45;
    final crateHeight = size * 1.15;

    final rect = Rect.fromLTWH(
      x - crateWidth / 2,
      groundY - crateHeight,
      crateWidth,
      crateHeight,
    );

    // =====================================================
    // COLORS
    // =====================================================

    const frameColor = Color(0xFF262626);
    const plankColor = Color(0xFF3D3D3D);
    const darkLine = Color(0xFF111111);
    const nailColor = Color(0xFFC2C2C2);

    // =====================================================
    // MAIN BODY
    // =====================================================

    canvas.drawRect(
      rect,
      Paint()..color = frameColor,
    );

    // =====================================================
    // INNER PANEL
    // =====================================================

    const border = 10.0;

    final inner = Rect.fromLTWH(
      rect.left + border,
      rect.top + border,
      rect.width - border * 2,
      rect.height - border * 2,
    );

    // =====================================================
    // PLANKS
    // =====================================================

    const plankCount = 5;
    final plankWidth = inner.width / plankCount;

    final random = Random(42);

    for (int i = 0; i < plankCount; i++) {
      final plankRect = Rect.fromLTWH(
        inner.left + i * plankWidth,
        inner.top,
        plankWidth - 2,
        inner.height,
      );

      // plank body
      canvas.drawRect(
        plankRect,
        Paint()..color = plankColor,
      );

      // =================================================
      // RANDOM WOOD DETAILS
      // =================================================

      final scratchPaint = Paint()
        ..color = Colors.black.withOpacity(0.33)
        ..strokeWidth = 1.6;

      // random vertical cracks
      final crackCount = 3 + random.nextInt(3);

      for (int c = 0; c < crackCount; c++) {
        final startX =
            plankRect.left + random.nextDouble() * plankRect.width;

        final startY =
            plankRect.top + random.nextDouble() * 25;

        final segments = 4 + random.nextInt(4);

        double currentX = startX;
        double currentY = startY;

        for (int s = 0; s < segments; s++) {
          final nextX =
              currentX + (-2 + random.nextDouble() * 4);

          final nextY =
              currentY + 10 + random.nextDouble() * 12;

          canvas.drawLine(
            Offset(currentX, currentY),
            Offset(nextX, nextY),
            scratchPaint,
          );

          currentX = nextX;
          currentY = nextY;

          if (currentY > plankRect.bottom - 6) break;
        }
      }

      // random small wood marks
      for (int m = 0; m < 5; m++) {
        final mx =
            plankRect.left + random.nextDouble() * plankRect.width;

        final my =
            plankRect.top + random.nextDouble() * plankRect.height;

        canvas.drawLine(
          Offset(mx - 2, my),
          Offset(mx + 2, my + 1),
          scratchPaint,
        );
      }

      // =================================================
      // GAPS BETWEEN PLANKS
      // =================================================

      if (i != plankCount - 1) {
        final gapX = plankRect.right + 1;

        canvas.drawLine(
          Offset(gapX, inner.top),
          Offset(gapX, inner.bottom),
          Paint()
            ..color = darkLine
            ..strokeWidth = 2.4,
        );
      }
    }

    // =====================================================
    // OUTER FRAME
    // =====================================================

    final framePaint = Paint()
      ..color = frameColor;

    const beam = 10.0;

    // top
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top, rect.width, beam),
      framePaint,
    );

    // bottom
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.bottom - beam, rect.width, beam),
      framePaint,
    );

    // left
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top, beam, rect.height),
      framePaint,
    );

    // right
    canvas.drawRect(
      Rect.fromLTWH(rect.right - beam, rect.top, beam, rect.height),
      framePaint,
    );

    // =====================================================
    // FRAME DETAIL LINES
    // =====================================================

    final frameLine = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(rect.left + 8, rect.top + beam),
      Offset(rect.right - 8, rect.top + beam),
      frameLine,
    );

    canvas.drawLine(
      Offset(rect.left + 8, rect.bottom - beam),
      Offset(rect.right - 8, rect.bottom - beam),
      frameLine,
    );

    // =====================================================
    // METAL NAILS
    // =====================================================

    final nailPaint = Paint()
      ..color = nailColor;

    final nailOutline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.black;

    final nails = [
      Offset(rect.left + 7, rect.top + 7),
      Offset(rect.right - 7, rect.top + 7),
      Offset(rect.left + 7, rect.bottom - 7),
      Offset(rect.right - 7, rect.bottom - 7),
    ];

    for (final nail in nails) {
      canvas.drawCircle(nail, 4, nailPaint);
      canvas.drawCircle(nail, 4, nailOutline);
    }

    // =====================================================
    // OUTLINE
    // =====================================================

    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = Colors.black,
    );
  }
}