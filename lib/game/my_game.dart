import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/obstacle_manager.dart';
import '../obstacles/obstacle.dart';
import '../state/game_state_provider.dart';
import '../world/level_data.dart';
import '../world/world_theme.dart';


import 'background.dart';
import 'fog.dart';
import 'ground.dart';
import 'player.dart';

class MyGame extends FlameGame with TapCallbacks {
  final WidgetRef ref;

  late Player player;
  late Background background;
  late Ground ground;
  late Fog fog;
  late ObstacleManager obstacleManager;

  bool isGameOver = false;

  bool isHolding = false;
  final int level;

  MyGame({
    required this.ref,
    required this.level,
  });

  @override
  Future<void> onLoad() async {

    final levelData = levels.firstWhere(
      (e) => e.level == level,
    );

    final theme = levelData.theme;


    final screenHeight = size.y;
    final groundHeight = screenHeight * 0.25;

    camera.viewfinder.visibleGameSize =
        Vector2(800, 400);

    background = Background(theme: theme);
    ground = Ground(theme: theme);
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

    // COLLISION
    for (final component in children.whereType<Obstacle>()) {
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


    // TODO :: check if the level is completed through lastProp isFinishProp in ground base.
    // LEVEL COMPLETE CHECK

    bool blocked = false;
    bool standingOnPlatform = false;
    final groundY = size.y - (size.y * 0.25) - 60;


    for (final component in children.whereType<Ground>()) {

      for (final prop in component.props) {

        if (!prop.isFinishProp) continue;

        final propWorldX = prop.x + component.groundOffset;

        // when player passes final prop
        if (player.position.x > propWorldX) {
          _completeLevel();
          return;
        }
      }

      for (final prop in component.props) {

        if (prop.collisionType == PropCollisionType.none) {
          continue;
        }

        final rect = prop.collisionRect(
          ground.groundOffset,
          size.y - (size.y * 0.25),
        );

        final playerRect = player.hitbox;
        if (!playerRect.overlaps(rect)) {
          // blocked = true;
          // break;
          continue;
        }

        
        final playerBottom = playerRect.bottom;
        final playerTop = playerRect.top;

        final previousBottom =
            playerBottom - player.velocityY * dt;

        // LANDING ON TOP
        final landing =
            previousBottom <= rect.top &&
            playerBottom >= rect.top;

        if (landing) {
          player.position.y = rect.top - 60;
          player.velocityY = 0;

          standingOnPlatform = true;
          continue;
        }

        // SIDE BLOCK
        final sideHit =
            playerBottom > rect.top + 10;

        if (sideHit) {
          blocked = true;
        }
      }
    }

    if (!standingOnPlatform && player.position.y < groundY) {
    // gravity naturally pulls him down
    }

    // WORLD MOVEMENT
    background.isMoving = isHolding && !blocked;
    ground.isMoving = isHolding && !blocked;
  }

  void _completeLevel() {
    if (isGameOver) return;

    isGameOver = true;

    pauseEngine();

    // update Riverpod state
    ref.read(gameStateProvider.notifier).completeCurrentLevel();
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
    ref.read(gameStateProvider.notifier).addCoins(1);
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