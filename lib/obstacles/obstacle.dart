import 'dart:ui';

import 'package:flame/components.dart';
import '../game/player.dart';
import '../game/my_game.dart';

abstract class Obstacle extends PositionComponent
    with HasGameReference<MyGame> {

  double speed = 220;

  Obstacle({
    required Vector2 position,
    required Vector2 size,
  }) {
    this.position = position;
    this.size = size;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Move left
    // position.x -= speed * dt;

    // Remove if off screen
    if (position.x + size.x < 0) {
      removeFromParent();
    }
  }

  /// Simple collision check
  bool collidesWith(Player player) {
    return toRect().overlaps(player.toRect());
  }

  /// What happens on collision
  void onPlayerCollision(Player player);
}


abstract class GroundProp {
  double x;
  double speed;
  bool isFinishProp = false;

  GroundProp(this.x, this.speed);

  void render(Canvas canvas, double Function(double x) getTerrainY);

  bool checkCollision(double playerX) {
    return false;
  }
}