import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'my_game.dart';
import '../obstacles/barrel_prop.dart';
import '../obstacles/crate_prop.dart';
import '../obstacles/obstacle.dart';
import '../obstacles/electric_pole_prop.dart';

class Ground extends Component with HasGameReference<MyGame> {
  bool isMoving = false;
  double groundOffset = 0;
  double _time = 0;
  
  final List<GroundProp> props = [];
  final List<_GrassBlade> grass = [];
  final List<_GrassBlade> foregroundGrass = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _generateProps();

    // _generateGrass();
    // _generateForegroundGrass();

  }

  void _generateForegroundGrass() {
    foregroundGrass.clear();

    final rand = Random();
    double x = 0;

    while (x < game.size.x * 1.2) {
      final height = 10 + rand.nextDouble() * 20; // taller
      final thickness = 2 + rand.nextDouble() * 3; // thicker
      final tilt = (rand.nextDouble() - 0.5) * 0.6;

      foregroundGrass.add(_GrassBlade(x, height, thickness, tilt));

      x += 3 + rand.nextDouble() * 6;
    }
  }

  void _generateGrass() {
    grass.clear();

    final rand = Random();
    double x = 0;

    while (x < game.size.x * 1.2) {
      final height = 8 + rand.nextDouble() * 18; // random height
      final thickness = 1 + rand.nextDouble() * 2; // thin to slightly thick
      final tilt = (rand.nextDouble() - 0.5) * 0.5; // slight left/right tilt

      grass.add(_GrassBlade(x, height, thickness, tilt));

      x += 2 + rand.nextDouble() * 4; // uneven spacing
    }
  }

  void _generateProps() {
    props.clear();

    final rand = Random();

    double x = 100;

    GroundProp? lastProp;

    while (x < game.size.x * 1.5) {
      final type = rand.nextInt(3);

      late GroundProp prop;

      if (type == 0) {
        prop = BarrelProp(
          x: x,
          width: 38 + rand.nextDouble() * 14,
          height: 46 + rand.nextDouble() * 14,
        );
      } else if (type == 1) {
        prop = CrateProp(
          x: x,
          size: 42 + rand.nextDouble() * 16,
        );
      } else {
        prop = ElectricPoleProp(
          x: x,
          height: 140 + rand.nextDouble() * 60,
        );
      }

      props.add(prop);
      lastProp = prop;

      x += 180 + rand.nextDouble() * 260;
    }

    // ✅ Mark final prop as level finish
    if (lastProp != null) {
      lastProp.isFinishProp = true;
    }
  }


  double _terrainHeight(double x) {
    return sin((x + groundOffset) * 0.01) * 10
        + sin((x + groundOffset) * 0.03) * 5;
  }

  double terrainY(double x, double screenHeight, double groundHeight) {
    // return screenHeight - groundHeight + _terrainHeight(x);
    return screenHeight - groundHeight;
  }

  @override
  void render(Canvas canvas) {
    final screenHeight = game.size.y;
    final groundHeight = screenHeight * 0.25;

    final paint = Paint()..color = Colors.grey.shade600;


    // canvas.drawRect(
    //   Rect.fromLTWH(0, screenHeight - groundHeight, game.size.x, groundHeight),
    //   paint,
    // );

    final path = Path();

    double startX = -game.size.x;
    double endX = game.size.x * 2;

    for (double x = startX; x < endX; x += 10) {
      // final y = screenHeight - groundHeight + _terrainHeight(x);
      final y = screenHeight - groundHeight;

      if (x == startX) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // close bottom shape
    path.lineTo(endX, screenHeight);
    path.lineTo(startX, screenHeight);
    path.close();

    canvas.drawPath(
      path,
      Paint()..color = Colors.grey.shade600,
    );
    
    
    _drawProps(canvas, screenHeight, groundHeight);
    
    // draw grass ON TOP of ground
    _drawGrass(canvas, screenHeight, groundHeight);
    _drawForegroundGrass(canvas, screenHeight, groundHeight); // foreground grass

  }

  @override
  void update(double dt) {
    _time += dt;

    if (!isMoving) return;

    groundOffset -= 220 * dt;

    // loop seamlessly
    if (groundOffset.abs() > game.size.x) {
      groundOffset = 0;
    }
  }

  void _drawGrass(Canvas canvas, double screenHeight, double groundHeight) {
    final groundY = screenHeight - groundHeight + 4;

    final paint = Paint()
      ..color = Colors.grey.shade800.withOpacity(0.85)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final rand = Random();

    double x = 0;

    while (x < game.size.x) {
      // clustering effect (sometimes dense, sometimes sparse)
      x += 2 + rand.nextDouble() * 6;

      final height = 4 + rand.nextDouble() * 10;

      // wind sway base
      final sway = sin((_time * 1.5) + x * 0.05) * 2.5;

      // slight leaning per blade
      final lean = (rand.nextDouble() - 0.5) * 4;

      final baseX = x + groundOffset;
      // final baseY = screenHeight - groundHeight + _terrainHeight(baseX);
      final baseY = screenHeight - groundHeight;

      final tipX = baseX + sway + lean;
      final tipY = baseY - height;

      // CURVED blade instead of straight spike
      final path = Path();
      path.moveTo(baseX, baseY);

      path.quadraticBezierTo(
        baseX + sway * 0.5,
        baseY - height * 0.6,
        tipX,
        tipY,
      );

      canvas.drawPath(path, paint);
    }
  }

  void _drawForegroundGrass(Canvas canvas, double screenHeight, double groundHeight) {
    final groundY = screenHeight - groundHeight;

    final paint = Paint()
      ..strokeCap = StrokeCap.round;

    for (final g in foregroundGrass) {
      final sway = sin(_time * 1.8 + g.phase) * 0.4;

      final baseX = g.x + groundOffset;
      // final baseY = screenHeight - groundHeight + _terrainHeight(baseX);
      final baseY = screenHeight - groundHeight;

      final tipX = baseX + (g.baseTilt + sway) * g.height;
      final tipY = baseY - g.height;

      paint
        ..color = Colors.black // darker = closer
        ..strokeWidth = g.thickness;

      canvas.drawLine(Offset(baseX, baseY), Offset(tipX, tipY), paint);
    }
  }


  void _drawProps(Canvas canvas, double screenHeight, double groundHeight) {
    final groundY = screenHeight - groundHeight;

    for (final p in props) {
      canvas.save();
      canvas.translate(groundOffset, 0);

      p.render(canvas, (x) => terrainY(x, screenHeight, groundHeight));

      canvas.restore();
    }
  }
}

class _GrassBlade {
  final double x;
  final double height;
  final double thickness;
  double baseTilt;
  double phase; // for animation offset

  _GrassBlade(this.x, this.height, this.thickness, this.baseTilt)
      : phase = Random().nextDouble() * 2 * pi;
}