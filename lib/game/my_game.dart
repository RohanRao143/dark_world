import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

import '../logic/obstacle_manager.dart';
import '../obstacles/obstacle.dart';

import 'background.dart';
import 'fog.dart';
import 'ground.dart';
import 'player.dart';

class MyGame extends FlameGame with TapCallbacks {
  late Player player;
  late Background background;
  late Ground ground;
  late Fog fog;
  late ObstacleManager obstacleManager;

  bool isGameOver = false;

  bool isHolding = false;

  @override
  Future<void> onLoad() async {
    final screenHeight = size.y;
    final groundHeight = screenHeight * 0.25;

    camera.viewfinder.visibleGameSize =
        Vector2(800, 400);

    background = Background();
    ground = Ground();
    fog = Fog();

    player = Player()
      ..position = Vector2(
        150,
        screenHeight - groundHeight - 60,
      );

    add(background);
    add(ground);
    add(player);
    add(fog);

    player.setGround(
      screenHeight - groundHeight - 60,
    );

    obstacleManager = ObstacleManager();

    add(obstacleManager);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isGameOver) return;

    // WORLD MOVEMENT
    background.isMoving = isHolding;
    ground.isMoving = isHolding;

    // COLLISION
    for (final component
        in children.whereType<Obstacle>()) {
      if (component.collidesWith(player)) {
        if (player.isBreaking) {
          component.removeFromParent();
        } else {
          component.onPlayerCollision(player);
          return;
        }

        return;
      }
    }
  }

  void gameOver() {
    if (isGameOver) return;

    isGameOver = true;

    isHolding = false;

    pauseEngine();
  }

  // Optional tap jump

  @override
  void onTapDown(TapDownEvent event) {
    player.jumpPressed();
  }

  @override
  void onTapUp(TapUpEvent event) {
    player.jumpReleased();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    player.jumpReleased();
  }
}