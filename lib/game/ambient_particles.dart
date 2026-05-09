import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'my_game.dart';

class Particle {
  Offset pos;
  double size;
  double speedX;
  double speedY;
  double glow;

  Particle({
    required this.pos,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.glow,
  });
}

class AmbientParticles extends Component with HasGameReference<MyGame> {
  final List<Particle> particles = [];
  final int count;

  AmbientParticles({this.count = 50});

  @override
  Future<void> onLoad() async {
    final rand = Random();
    for (int i = 0; i < count; i++) {
      particles.add(Particle(
        pos: Offset(rand.nextDouble() * game.size.x, rand.nextDouble() * game.size.y * 0.7),
        size: rand.nextDouble() * 2 + 1,
        speedX: rand.nextDouble() * 10 - 5,
        speedY: rand.nextDouble() * 5 - 2.5,
        glow: rand.nextDouble() * 0.6 + 0.4,
      ));
    }
  }

  @override
  void update(double dt) {
    for (final p in particles) {
      p.pos = p.pos.translate(p.speedX * dt, p.speedY * dt);

      // wrap around edges
      if (p.pos.dx < 0) p.pos = Offset(game.size.x, p.pos.dy);
      if (p.pos.dx > game.size.x) p.pos = Offset(0, p.pos.dy);
      if (p.pos.dy < 0) p.pos = Offset(p.pos.dx, game.size.y * 0.7);
      if (p.pos.dy > game.size.y * 0.7) p.pos = Offset(p.pos.dx, 0);
    }
  }

  @override
  void render(Canvas canvas) {
    for (final p in particles) {
      final paint = Paint()..color = Colors.white.withOpacity(p.glow);
      canvas.drawCircle(p.pos, p.size, paint);
      canvas.drawCircle(p.pos, p.size * 2, paint..maskFilter = MaskFilter.blur(BlurStyle.normal, 2));
    }
  }
}