// bats.dart

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class FlyingBat {
  double x;
  double y;

  final double speed;
  final bool moveRight;

  bool active = true;

  FlyingBat({
    required this.x,
    required this.y,
    required this.speed,
    required this.moveRight,
  });

  void update(double dt) {
    x += moveRight ? speed * dt : -speed * dt;

    // floating movement
    y += sin(x * 0.04) * 0.3;

    // remove when off-screen
    if (x < -300 || x > 5000) {
      active = false;
    }
  }

  void render(Canvas canvas) {
    final wingPaint = Paint()
      ..color = const Color(0xFF050505);

    final bodyPaint = Paint()
      ..color = const Color(0xFF111111);

    // BODY
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, y),
        width: 12,
        height: 7,
      ),
      bodyPaint,
    );

    // LEFT WING
    final leftWing = Path()
      ..moveTo(x - 2, y)
      ..quadraticBezierTo(
        x - 15,
        y - 9,
        x - 24,
        y,
      )
      ..quadraticBezierTo(
        x - 15,
        y + 5,
        x - 2,
        y + 1,
      );

    // RIGHT WING
    final rightWing = Path()
      ..moveTo(x + 2, y)
      ..quadraticBezierTo(
        x + 15,
        y - 9,
        x + 24,
        y,
      )
      ..quadraticBezierTo(
        x + 15,
        y + 5,
        x + 2,
        y + 1,
      );

    canvas.drawPath(leftWing, wingPaint);
    canvas.drawPath(rightWing, wingPaint);

    // ears
    final earPaint = Paint()
      ..color = Colors.black;

    final leftEar = Path()
      ..moveTo(x - 4, y - 2)
      ..lineTo(x - 1, y - 8)
      ..lineTo(x + 1, y - 2)
      ..close();

    final rightEar = Path()
      ..moveTo(x + 4, y - 2)
      ..lineTo(x + 1, y - 8)
      ..lineTo(x - 1, y - 2)
      ..close();

    canvas.drawPath(leftEar, earPaint);
    canvas.drawPath(rightEar, earPaint);
  }
}

// =========================================================
// BAT MANAGER
// =========================================================

class BatManager {
  final List<FlyingBat> bats = [];

  final Random _random = Random();

  double _spawnTimer = 0;

  void update(
    double dt,
    List<double> poleXs,
    double Function(double) getTerrainY,
  ) {
    _spawnTimer += dt;

    // spawn occasionally
    if (_spawnTimer > 5 + _random.nextDouble() * 4) {
      _spawnTimer = 0;

      if (poleXs.isNotEmpty) {
        final poleX = poleXs[
            _random.nextInt(poleXs.length)];

        final moveRight = _random.nextBool();

        bats.add(
          FlyingBat(
            x: poleX,
            y: getTerrainY(poleX) - 170,
            speed: 120 + _random.nextDouble() * 50,
            moveRight: moveRight,
          ),
        );
      }
    }

    for (final bat in bats) {
      bat.update(dt);
    }

    bats.removeWhere((b) => !b.active);
  }

  void render(Canvas canvas) {
    for (final bat in bats) {
      bat.render(canvas);
    }
  }
}