import 'dart:ui';
import 'package:flutter/material.dart';
import 'obstacle.dart';

class ElectricPoleProp extends GroundProp {
  final double height;

  ElectricPoleProp({
    required double x,
    required this.height,
    double speed = 120, // default scroll speed
  }) : super(x, speed);
@override
void render(Canvas canvas, double Function(double) getTerrainY) {
  final groundY = getTerrainY(x);

  // taller pole
  final poleTop = groundY - (height * 1.15);

  // =====================================================
  // PAINTS
  // =====================================================

  final polePaint = Paint()
    ..color = const Color(0xFF1C1C1C)
    ..strokeWidth = 6
    ..strokeCap = StrokeCap.round;

  final armPaint = Paint()
    ..color = const Color(0xFF2A2A2A)
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;

  final lampPaint = Paint()
    ..color = const Color(0xFF505050);

  // =====================================================
  // MAIN POLE
  // =====================================================

  canvas.drawLine(
    Offset(x, groundY),
    Offset(x, poleTop),
    polePaint,
  );

  // =====================================================
  // SIMPLE STRAIGHT ARM
  // =====================================================

  final armY = poleTop + 38;

  canvas.drawLine(
    Offset(x, armY),
    Offset(x + 18, armY),
    armPaint,
  );

  // =====================================================
  // SMALL LAMP
  // =====================================================

  final lampRect = Rect.fromLTWH(
    x + 16,
    armY + 1,
    8,
    5,
  );

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      lampRect,
      const Radius.circular(1.5),
    ),
    lampPaint,
  );
}
}