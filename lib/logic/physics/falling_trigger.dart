import 'package:flame/components.dart';
import '../../game/my_game.dart';
import '../obsctacle_physics.dart';

class FallingTrigger extends Component with HasGameReference<MyGame> {
  final PhysicsObstacle target;
  final double triggerX;

  FallingTrigger({
    required this.target,
    required this.triggerX,
  });

  @override
  void update(double dt) {
    super.update(dt);

    if (target.isFalling) return;

    if (game.player.position.x >= triggerX) {
      target.isFalling = true; // 🔥 ONLY vertical drop
      removeFromParent();
    }
  }
}