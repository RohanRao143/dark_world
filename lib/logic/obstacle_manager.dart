import 'dart:math';
import 'package:flame/components.dart';

import '../game/my_game.dart';
// import '../obstacles/breakable_box.dart';
// import '../obstacles/swinging_crate.dart';
// import '../obstacles/limbo_obstacle.dart';

import '../logic/physics/falling_trigger.dart';


class ObstacleManager extends Component
    with HasGameReference<MyGame> {

  final Random _rand = Random();

  double spawnTimer = 0;
  double spawnInterval = 1.8;

  @override
  void update(double dt) {
    super.update(dt);

    // if (!game.isHolding) return; // only spawn when running

    spawnTimer += dt;

    // print("ObstacleManager running"); // 👈 DEBUG

    if (spawnTimer >= spawnInterval) {
      spawnTimer = 0;
      // _spawn();
    }
  }
  // void _spawn() {
  //   final groundY = game.player.groundY;

  //   final spawnX = 600.0; // 🔥 HARD FIXED POSITION

  //   final box = BreakableBox(
  //     position: Vector2(spawnX, groundY - 40),
  //     groundY: groundY,
  //   );

  //   print("Spawning box at $spawnX"); // DEBUG

  //   game.add(box);
    

  //   // final groundY = game.player.groundY;
  //   // final spawnX = game.size.x + 200;

  //   // final type = _rand.nextInt(3);

  //   // if (type == 0) {
  //   //   // falling breakable box
  //   //   final box = BreakableBox(
  //   //     position: Vector2(spawnX, groundY - 250),
  //   //     groundY: groundY,
  //   //   );

  //   //   game.add(box);

  //   //   game.add(
  //   //     FallingTrigger(
  //   //       target: box,
  //   //       triggerX: spawnX - 120,
  //   //     ),
  //   //   );
  //   // } else if (type == 1) {
  //   //   // swinging crate
  //   //   game.add(
  //   //     SwingingCrate(
  //   //       position: Vector2(spawnX, groundY - 200),
  //   //     ),
  //   //   );
  //   // } else {
  //   //   // static ground box
  //   //   game.add(
  //   //     BreakableBox(
  //   //       position: Vector2(spawnX, groundY - 44),
  //   //       groundY: groundY,
  //   //     ),
  //   //   );
  //   // }
  // }
}