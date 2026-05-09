import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'my_game.dart';

class Background extends Component with HasGameReference<MyGame> {
  bool isMoving = false;

  final Random _rand = Random();
  final Random _fxRand = Random();

  // =========================
  // ATMOSPHERIC FX
  // =========================

  final List<_DustParticle> dust = [];
  double _fogScroll = 0;

  // =========================
  // PARALLAX OFFSETS
  // =========================

  double starsOffset = 0;
  double moonOffset = 0;
  double mountainsOffset = 0;
  double foregroundOffset = 0;

  // =========================
  // WORLD LAYERS
  // =========================

  final List<_Building> farBuildings = [];
  final List<_Building> midBuildings = [];
  final List<_Building> nearBuildings = [];

  final List<_Mountain> mountains = [];
  final List<_Star> stars = [];

  final List<double> poles = [];

  // =========================
  // LOAD
  // =========================

  @override
  Future<void> onLoad() async {
    _generateBuildings(farBuildings, 60, 120, Colors.grey.shade700, 0.4);
    _generateBuildings(midBuildings, 100, 160, Colors.grey.shade800, 0.55);
    _generateBuildings(nearBuildings, 140, 220, Colors.grey.shade900, 0.7);

    _generateMountains();
    _generateStars();
    // _generateForeground();
    _generateDust();
  }

  // =========================
  // FX GENERATION
  // =========================

  void _generateDust() {
    dust.clear();

    final w = game.size.x * 2;
    final h = game.size.y;

    for (int i = 0; i < 80; i++) {
      dust.add(
        _DustParticle(
          pos: Offset(
            _fxRand.nextDouble() * w,
            _fxRand.nextDouble() * h,
          ),
          speed: 10 + _fxRand.nextDouble() * 30,
          size: 0.5 + _fxRand.nextDouble() * 1.5,
          alpha: 0.05 + _fxRand.nextDouble() * 0.15,
        ),
      );
    }
  }

  // =========================
  // GENERATORS
  // =========================

  void _generateForeground() {
    poles.clear();
    for (double x = 0; x < game.size.x * 2; x += 180) {
      poles.add(x);
    }
  }

  void _generateStars() {
    stars.clear();

    final w = game.size.x;
    final h = game.size.y;

    for (int i = 0; i < 40; i++) {
      stars.add(
        _Star(
          Offset(
            _rand.nextDouble() * w * 2,
            _rand.nextDouble() * (h * 0.75),
          ),
          _rand.nextDouble() < 0.7 ? 1.0 : 2.5,
          _rand.nextDouble() * 0.8 + 0.2,
        ),
      );
    }
  }

  void _generateMountains() {
    mountains.clear();

    double x = 0;

    while (x < game.size.x * 2) {
      final width = 180 + _rand.nextDouble() * 140;
      final height = 40 + _rand.nextDouble() * 100;

      mountains.add(
        _Mountain(
          x,
          width,
          height,
          Colors.grey.shade800,
        ),
      );

      x += width * 0.6;
    }
  }

  void _generateBuildings(
    List<_Building> list,
    double minH,
    double maxH,
    Color color,
    double speed,
  ) {
    double x = 0;

    while (x < game.size.x * 2) {
      final width = 60 + _rand.nextDouble() * 60;
      final height = minH + _rand.nextDouble() * (maxH - minH);

      final windows = _generateWindows(width, height);
      final lit = List<bool>.generate(windows.length, (_) => _rand.nextBool());

      list.add(
        _Building(
          x: x,
          width: width,
          height: height,
          color: color,
          speed: speed,
          windows: windows,
          litWindows: lit,
        ),
      );

      x += width + 160;
    }
  }

  List<Offset> _generateWindows(double w, double h) {
    final list = <Offset>[];
    final count = 2 + _rand.nextInt(4);

    for (int i = 0; i < count; i++) {
      list.add(
        Offset(
          _rand.nextDouble() * (w - 10),
          _rand.nextDouble() * (h - 16),
        ),
      );
    }

    return list;
  }

  // =========================
  // UPDATE
  // =========================

  @override
  void update(double dt) {
    _fogScroll += dt * 20;

    // dust movement
    for (final d in dust) {
      final wind = sin(_fogScroll * 0.002 + d.pos.dy * 0.01);

      d.pos = Offset(
        d.pos.dx - (d.speed * 0.2 + wind * 2) * dt,
        d.pos.dy + sin(_fogScroll * 0.003 + d.pos.dx * 0.01) * 0.3,
      );

      // wrap inside SCREEN (not world)
      if (d.pos.dx < 0) {
        d.pos = Offset(
          game.size.x,
          _fxRand.nextDouble() * game.size.y,
        );
      }
    }

    if (!isMoving) return;

    const baseSpeed = 120.0;

    starsOffset += baseSpeed * 0.02 * dt;
    mountainsOffset += baseSpeed * 0.04 * dt;
    foregroundOffset += baseSpeed * 1.0 * dt;


    _updateLayer(farBuildings, dt);
    _updateLayer(midBuildings, dt);
    _updateLayer(nearBuildings, dt);
  }

  void _updateLayer(List<_Building> list, double dt) {
    for (final b in list) {
      b.x -= b.speed * 120 * dt;
    }

    final first = list.first;
    final last = list.last;

    if (first.x + first.width < 0) {
      first.x = last.x + 160;
      list.removeAt(0);
      list.add(first);
    }
  }

  // =========================
  // RENDER
  // =========================

  @override
  void render(Canvas canvas) {
    final size = game.size;
    final groundH = size.y * 0.25;
    final horizonY = size.y - groundH;

    _drawSky(canvas, size);
    _drawBloom(canvas);

    _drawStars(canvas);
    _drawDust(canvas);
    _drawMoon(canvas);

    _drawMountains(canvas, horizonY);

    _drawLayer(canvas, farBuildings, horizonY);
    _drawLayer(canvas, midBuildings, horizonY);
    _drawLayer(canvas, nearBuildings, horizonY);

    _drawFog(canvas, size);
    _drawForeground(canvas, horizonY);
    _drawVignette(canvas);
  }

  // =========================
  // SKY
  // =========================

  void _drawSky(Canvas canvas, Vector2 size) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    final grad = LinearGradient(
      colors: [Colors.black, Colors.grey.shade900],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    canvas.drawRect(rect, Paint()..shader = grad.createShader(rect));
  }

  // =========================
  // BLOOM
  // =========================

  void _drawBloom(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, game.size.x, game.size.y),
      Paint()
        ..color = Colors.white.withOpacity(0.05)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
    );
  }

  // =========================
  // STARS
  // =========================

  void _drawStars(Canvas canvas) {
    final w = game.size.x * 2;

    for (final s in stars) {
      double x = (s.pos.dx - starsOffset) % w;
      if (x < 0) x += w;

      final glow = Paint()
        ..color = Colors.white.withOpacity(s.glow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(Offset(x, s.pos.dy), s.size * 2.5, glow);

      canvas.drawCircle(
        Offset(x, s.pos.dy),
        s.size,
        Paint()..color = Colors.white.withOpacity(0.9),
      );
    }
  }

  // =========================
  // DUST
  // =========================

  void _drawDust(Canvas canvas) {
    for (final d in dust) {
      canvas.drawCircle(
        d.pos,
        d.size,
        Paint()..color = Colors.white.withOpacity(d.alpha),
      );
    }
  }

  // =========================
  // MOON
  // =========================

  void _drawMoon(Canvas canvas) {
    final w = game.size.x * 2;

    double x = (650 - moonOffset) % w;
    if (x < 0) x += w;

    final c = Offset(x, 100);

    canvas.drawCircle(
      c,
      60,
      Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40),
    );

    canvas.drawCircle(c, 22, Paint()..color = Colors.grey.shade200);

    canvas.drawCircle(
      Offset(c.dx + 6, c.dy),
      22,
      Paint()..color = Colors.black.withOpacity(0.2),
    );
  }

  // =========================
  // MOUNTAINS
  // =========================

  void _drawMountains(Canvas canvas, double horizonY) {
    final w = game.size.x * 2;

    for (final m in mountains) {
      double x = (m.x - mountainsOffset) % w;
      if (x < -m.width) x += w;

      final path = Path()
        ..moveTo(x, horizonY)
        ..quadraticBezierTo(
          x + m.width / 2,
          horizonY - m.height,
          x + m.width,
          horizonY,
        )
        ..lineTo(x + m.width, horizonY)
        ..lineTo(x, horizonY)
        ..close();

      canvas.drawPath(path, Paint()..color = m.color);
    }
  }

  // =========================
  // BUILDINGS
  // =========================

  void _drawLayer(Canvas canvas, List<_Building> list, double hY) {
    for (final b in list) {
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(b.x, hY - b.height, b.width, b.height),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      );

      canvas.drawRRect(rect, Paint()..color = b.color);

      for (int i = 0; i < b.windows.length; i++) {
        final w = b.windows[i];
        final lit = b.litWindows[i];

        canvas.drawRect(
          Rect.fromLTWH(
            b.x + w.dx,
            hY - b.height + w.dy,
            6,
            12,
          ),
          Paint()
            ..color = lit
                ? Colors.yellow.withOpacity(0.6)
                : Colors.black.withOpacity(0.2),
        );
      }
    }
  }

  // =========================
  // FOG
  // =========================

  void _drawFog(Canvas canvas, Vector2 size) {
    // final rect = Rect.fromLTWH(0, 0, size.x, size.y);

    // canvas.drawRect(
    //   rect,
    //   Paint()
    //     ..shader = LinearGradient(
    //       begin: Alignment.bottomCenter,
    //       end: Alignment.topCenter,
    //       colors: [
    //         Colors.black.withOpacity(0.55),
    //         Colors.black.withOpacity(0.25),
    //         Colors.transparent,
    //       ],
    //     ).createShader(rect)
    //     ..blendMode = BlendMode.screen,
    // );

    for (int i = 0; i < 4; i++) {
      final y = size.y * (0.35 + i * 0.18);

      final baseX = (_fogScroll * 0.2 + i * 220);

      final wobble = sin((_fogScroll * 0.01) + i * 1.7) * 50;

      final x = (baseX + wobble) % (size.x * 1.2);

      final opacity = 0.03 + i * 0.01;

      final fogPaint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: size.x * 1.3,
          height: 140 + i * 20,
        ),
        fogPaint,
      );
    }
  }

  // =========================
  // FOREGROUND
  // =========================

  void _drawForeground(Canvas canvas, double hY) {
    final w = game.size.x * 2;

    for (final p in poles) {
      double x = (p - foregroundOffset) % w;
      if (x < 0) x += w;

      final paint = Paint()..color = Colors.black.withOpacity(0.9);

      canvas.drawRect(Rect.fromLTWH(x, hY - 90, 6, 90), paint);

      canvas.drawRect(Rect.fromLTWH(x - 18, hY - 85, 40, 3), paint);
    }
  }

  // =========================
  // VIGNETTE
  // =========================

  void _drawVignette(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, game.size.x, game.size.y);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.1,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.6),
          ],
          stops: const [0.6, 1.0],
        ).createShader(rect)
        ..blendMode = BlendMode.multiply,
    );
  }
}

// =========================
// MODELS
// =========================

class _Building {
  double x;
  double width;
  double height;
  final Color color;
  final double speed;
  final List<Offset> windows;
  final List<bool> litWindows;

  _Building({
    required this.x,
    required this.width,
    required this.height,
    required this.color,
    required this.speed,
    required this.windows,
    required this.litWindows,
  });
}

class _Star {
  final Offset pos;
  final double size;
  final double glow;

  _Star(this.pos, this.size, this.glow);
}

class _Mountain {
  double x;
  double width;
  double height;
  final Color color;

  _Mountain(this.x, this.width, this.height, this.color);
}

class _DustParticle {
  Offset pos;
  double speed;
  double size;
  double alpha;

  _DustParticle({
    required this.pos,
    required this.speed,
    required this.size,
    required this.alpha,
  });
}