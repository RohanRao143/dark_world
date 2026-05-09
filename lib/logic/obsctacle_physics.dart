import 'package:flame/components.dart';
import '../obstacles/obstacle.dart';

abstract class PhysicsObstacle extends Obstacle {
  double velocityY = 0;
  double gravity = 1000;

  bool isFalling = false;
  bool isOnGround = false;

  late double groundY;

  PhysicsObstacle({
    required super.position,
    required super.size,
    required this.groundY,
  });

  @override
  void update(double dt) {
    super.update(dt);

    if (isFalling) {
      velocityY += gravity * dt;
      position.y += velocityY * dt;

      if (position.y >= groundY - size.y) {
        position.y = groundY - size.y;
        isFalling = false;
        isOnGround = true;

        velocityY = 0;
        onLand();
      }
    }
  }

  void onLand() {}
}