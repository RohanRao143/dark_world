import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'my_game.dart';

class Fog extends Component with HasGameReference<MyGame> {
  double _offsetX = 0;

  @override
  void update(double dt) {
    _offsetX += dt * 10; // horizontal speed
    if (_offsetX > game.size.x) _offsetX = 0;
  }

  @override
  void render(Canvas canvas) {
    final size = game.size;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withOpacity(0.2),
        Colors.transparent,
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect);

    // translate canvas horizontally for drift
    canvas.save();
    canvas.translate(-_offsetX, 0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x * 2, size.y), paint);
    canvas.restore();
  }
}