import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'my_game.dart';

class Silhouette extends Component with HasGameReference<MyGame> {
  final double x;
  final double height;
  final double width;
  final Color color;
  final double speed;

  Silhouette({
    required this.x,
    required this.height,
    required this.width,
    this.color = Colors.black,
    this.speed = 0.5,
  });

  double _posX = 0;

  @override
  Future<void> onLoad() async {
    _posX = x;
  }

  @override
  void update(double dt) {
    _posX -= speed * 50 * dt; // move left slowly
    if (_posX + width < 0) _posX = game.size.x + width; // recycle
  }

  @override
  void render(Canvas canvas) {
    final baseY = game.size.y * 0.75;

    final paint = Paint()..color = color;

    // tree trunk
    canvas.drawRect(Rect.fromLTWH(_posX, baseY - height, width, height), paint);

    // tree leaves (triangle)
    final path = Path();
    path.moveTo(_posX - width, baseY - height + 5);
    path.lineTo(_posX + width * 2, baseY - height + 5);
    path.lineTo(_posX + width / 2, baseY - height - height / 2);
    path.close();

    canvas.drawPath(path, paint);
  }
}