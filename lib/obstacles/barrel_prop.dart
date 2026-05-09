import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import './obstacle.dart';

class BarrelProp extends GroundProp {
  final double width;
  final double height;

  BarrelProp({
    required double x,
    required this.width,
    required this.height,
    double speed = 120,
  }) : super(x, speed);

  // =========================================================
  // STATIC RANDOM DATA
  // Generated ONCE so grain lines do NOT move every frame
  // =========================================================

  late final List<_WoodLine> _grainLines = List.generate(
    45,
    (_) => _WoodLine.random(),
  );

  late final List<_WoodLine> _topLines = List.generate(
    10,
    (_) => _WoodLine.random(),
  );

@override
void render(Canvas canvas, double Function(double) getTerrainY) {

  // =========================================================
  // FIXED NORMAL BARREL SIZE
  // =========================================================

  final double w = width;          // 👈 fixed width
  final double h = height * 1.35; // slightly short barrel

  final groundY = getTerrainY(x);

  final double left = x - w / 2;
  final double right = x + w / 2;
  final double top = groundY - h;
  final double bottom = groundY;

  // =========================================================
  // COLORS
  // =========================================================

  final bodyPaint = Paint()
    ..shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFF17191B),
        const Color(0xFF35393E),
        const Color(0xFF141618),
      ],
    ).createShader(Rect.fromLTWH(left, top, w, h));

  final outlinePaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke;

  final woodPaint = Paint()
    ..color = const Color(0xFF0C0D0E)
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  final bandPaint = Paint()
    ..shader = LinearGradient(
      colors: [
        const Color(0xFF050505),
        const Color(0xFF2D2D2D),
        const Color(0xFF050505),
      ],
    ).createShader(Rect.fromLTWH(left, top, w, h));

  final rivetPaint = Paint()
    ..color = const Color(0xFF0A0A0A);

  // =========================================================
  // MAIN BODY
  // =========================================================

  final bodyRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(left, top, w, h),
    const Radius.circular(6),
  );

  canvas.drawRRect(bodyRect, bodyPaint);
  canvas.drawRRect(bodyRect, outlinePaint);

  // =========================================================
  // WOOD PLANKS
  // =========================================================

  final plankCount = 7;
  final plankWidth = w / plankCount;

  for (int i = 1; i < plankCount; i++) {
    final px = left + plankWidth * i;

    canvas.drawLine(
      Offset(px, top + 6),
      Offset(px, bottom - 6),
      woodPaint,
    );
  }

  // =========================================================
  // STATIC RANDOM GRAIN
  // =========================================================

  for (final line in _grainLines) {
    final sx = left + line.sx * w;
    final sy = top + line.sy * h;

    canvas.drawLine(
      Offset(sx, sy),
      Offset(sx + line.dx, sy + line.dy),
      woodPaint,
    );
  }

  // =========================================================
  // METAL BANDS
  // =========================================================

  final bands = [
    top + h * 0.20,
    top + h * 0.50,
    top + h * 0.80,
  ];

  for (final by in bands) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(x, by),
        width: w,
        height: h * 0.075,
      ),
      const Radius.circular(4),
    );

    canvas.drawRRect(rect, bandPaint);
    canvas.drawRRect(rect, outlinePaint);

    // Rivets
    for (int i = 0; i < 6; i++) {
      final rx = left + w * 0.12 + i * (w * 0.15);

      canvas.drawCircle(
        Offset(rx, by),
        2.5,
        rivetPaint,
      );
    }
  }

  // =========================================================
  // TOP CAP
  // =========================================================

  final topOval = Rect.fromCenter(
    center: Offset(x, top + h * 0.05),
    width: w * 0.84,
    height: h * 0.08,
  );

  final topPaint = Paint()
    ..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF565C63),
        const Color(0xFF1A1C1E),
      ],
    ).createShader(topOval);

  canvas.drawOval(topOval, topPaint);
  canvas.drawOval(topOval, outlinePaint);

  // =========================================================
  // TOP WOOD DETAILS
  // =========================================================

  for (final line in _topLines) {
    final sx = left + w * 0.20 + line.sx * (w * 0.42);
    final sy = top + h * 0.02 + line.sy * 8;

    canvas.drawLine(
      Offset(sx, sy),
      Offset(
        sx + line.dx,
        sy + line.dy * 0.25,
      ),
      woodPaint,
    );
  }

  // =========================================================
  // HIGHLIGHT
  // =========================================================

  final highlightPaint = Paint()
    ..color = Colors.white.withOpacity(0.05);

  canvas.drawRect(
    Rect.fromLTWH(
      left + w * 0.16,
      top + 8,
      w * 0.08,
      h - 16,
    ),
    highlightPaint,
  );
}
}

// =========================================================
// STATIC RANDOM LINE MODEL
// =========================================================

class _WoodLine {
  final double sx;
  final double sy;
  final double dx;
  final double dy;

  _WoodLine({
    required this.sx,
    required this.sy,
    required this.dx,
    required this.dy,
  });

  factory _WoodLine.random() {
    final r = Random();

    return _WoodLine(
      sx: r.nextDouble(),
      sy: r.nextDouble(),
      dx: r.nextDouble() * 18 - 9,
      dy: r.nextDouble() * 18 - 9,
    );
  }
}