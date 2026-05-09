import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'my_game.dart';

class Player extends PositionComponent with HasGameReference<MyGame> {
  Player() {
    size = Vector2(40, 70);
  }

  // =========================================================
  // PHYSICS
  // =========================================================

  Vector2 velocity = Vector2.zero();

  bool isGrounded = true;

  // gravity
  double gravity = 1900;
  double fallGravityMultiplier = 1.8;
  double jumpForce = -720;
  double maxFallSpeed = 1400;

  // jump helpers
  double coyoteTime = 0.12;
  double coyoteTimer = 0;

  double jumpBufferTime = 0.12;
  double jumpBufferTimer = 0;

  bool jumpHeld = false;

  // =========================================================
  // STATES
  // =========================================================

  bool isRunning = false;
  bool isSliding = false;
  bool isBreaking = false;

  double animationTime = 0;

  double slideTimer = 0;
  double breakTimer = 0;

  double slideDuration = 0.6;
  double breakDuration = 0.4;

  late double groundY;

  // eyes
  bool eyesOpen = true;
  double blinkTimer = 0;

  // slide
  double slideOffset = 0;

  @override
  Future<void> onLoad() async {
    final groundHeight = game.size.y * 0.25;

    position = Vector2(
      150,
      game.size.y - groundHeight - size.y,
    );
  }

  void setGround(double y) {
    groundY = y;
    position.y = y;
  }

  // =========================================================
  // INPUT
  // =========================================================

  void jumpPressed() {
    jumpHeld = true;
    jumpBufferTimer = jumpBufferTime;
  }

  void jumpReleased() {
    jumpHeld = false;
  }

  void slide() {
    if (!isSliding && isGrounded) {
      isSliding = true;
      slideTimer = 0;
    }
  }

  void collide() {
    if (!isBreaking) {
      isBreaking = true;
      breakTimer = 0;
    }
  }

  // =========================================================
  // COLLISION BOX
  // =========================================================

  @override
  Rect toRect() {
    if (isSliding) {
      return Rect.fromLTWH(
        position.x,
        position.y + 35,
        size.x,
        size.y - 35,
      );
    }

    return super.toRect();
  }

  // =========================================================
  // UPDATE
  // =========================================================

  @override
  void update(double dt) {
    super.update(dt);

    // =====================================================
    // TIMERS
    // =====================================================

    jumpBufferTimer -= dt;
    coyoteTimer -= dt;

    // =====================================================
    // GRAVITY
    // =====================================================

    double gravityForce = gravity;

    // faster falling
    if (velocity.y > 0) {
      gravityForce *= fallGravityMultiplier;
    }

    // variable jump height
    if (!jumpHeld && velocity.y < 0) {
      gravityForce *= 2.2;
    }

    velocity.y += gravityForce * dt;

    velocity.y = velocity.y.clamp(
      -9999,
      maxFallSpeed,
    );

    // =====================================================
    // JUMP EXECUTION
    // =====================================================

    final canJump = isGrounded || coyoteTimer > 0;

    if (jumpBufferTimer > 0 && canJump) {
      velocity.y = jumpForce;

      isGrounded = false;

      jumpBufferTimer = 0;
      coyoteTimer = 0;
    }

    // =====================================================
    // APPLY VERTICAL MOVEMENT ONLY
    // =====================================================

    position.y += velocity.y * dt;

    // =====================================================
    // GROUND COLLISION
    // =====================================================

    if (position.y >= groundY) {
      position.y = groundY;

      velocity.y = 0;

      if (!isGrounded) {
        isGrounded = true;
      }

      coyoteTimer = coyoteTime;
    } else {
      if (isGrounded) {
        isGrounded = false;
        coyoteTimer = coyoteTime;
      }
    }

    // =====================================================
    // SLIDE
    // =====================================================

    if (isSliding) {
      slideTimer += dt;

      if (slideTimer >= slideDuration) {
        isSliding = false;
      }
    }

    // smooth body lowering
    if (isSliding) {
      slideOffset = lerpDouble(
        slideOffset,
        28,
        0.18,
      )!;
    } else {
      slideOffset = lerpDouble(
        slideOffset,
        0,
        0.18,
      )!;
    }

    // =====================================================
    // RUN ANIMATION
    // =====================================================

    if (game.isHolding && isGrounded) {
      animationTime += dt * 8;
      isRunning = true;
    } else {
      isRunning = false;
    }

    // =====================================================
    // BLINK
    // =====================================================

    blinkTimer += dt;

    if (blinkTimer > 3) {
      eyesOpen = false;

      if (blinkTimer > 3.2) {
        eyesOpen = true;
        blinkTimer = 0;
      }
    }

    // =====================================================
    // BREAK EFFECT
    // =====================================================

    if (isBreaking) {
      breakTimer += dt;

      if (breakTimer >= breakDuration) {
        isBreaking = false;
      }
    }
  }

  // =========================================================
  // RENDER
  // =========================================================

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final centerX = size.x / 2;

    final bodyPaint = Paint()
      ..color = Colors.black;

    final limbPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final handPaint = Paint()
      ..color = Colors.black;

    final swing = isRunning && isGrounded && !isSliding
        ? sin(animationTime) * 12
        : 0.0;

    final opposite = -swing;

    final headY = 14.0;
    final shoulderY = 26.0;
    final hipY = 52.0;
    final armY = shoulderY + 4;

    // lean
    double lean = 0.02;

    if (isRunning) lean = 0.08;

    if (!isGrounded) lean = 0.14;

    if (isSliding) lean = -0.25;

    // =====================================================
    // HEAD
    // =====================================================

    canvas.save();

    double headCoeff = 0.6;

    if (isSliding) {
      headCoeff = 0.95;
    }

    canvas.translate(
      centerX,
      // head should atached to torso
      headY + slideOffset * headCoeff,
    );

    canvas.rotate(lean);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: 24,
        height: 24,
      ),
      bodyPaint,
    );

    if (eyesOpen) {
      canvas.drawCircle(
        const Offset(4, -2),
        2,
        Paint()..color = Colors.white,
      );
    } else {
      canvas.drawLine(
        const Offset(3, -2),
        const Offset(6, -2),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5,
      );
    }

    final wave = sin(animationTime * 2) * 2;

    final hair = Path();

    hair.moveTo(-11, -2);

    hair.quadraticBezierTo(
      -14,
      -16,
      -2,
      -18,
    );

    hair.quadraticBezierTo(
      10,
      -20 + wave,
      14,
      -6,
    );

    hair.quadraticBezierTo(
      8,
      -10,
      4,
      -2,
    );

    hair.lineTo(-11, -2);

    canvas.drawPath(hair, bodyPaint);

    canvas.restore();

    // =====================================================
    // BODY
    // =====================================================

    canvas.save();

    canvas.translate(centerX, slideOffset);

    // double squash = 1.0;

    // if (isSliding) {
    //   squash = 0.72;
    // }

    // canvas.scale(1.0, squash);

    canvas.rotate(lean);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(
            0,
            (shoulderY + hipY) / 2,
          ),
          width: 16,
          height: hipY - shoulderY,
        ),
        const Radius.circular(5),
      ),
      bodyPaint,
    );

    // =====================================================
    // LIMBS
    // =====================================================

    Offset backKnee,
        backFoot,
        frontKnee,
        frontFoot;

    Offset backElbow,
        backHand,
        frontElbow,
        frontHand;

    if (!isGrounded) {

      // =====================================================
      // JUMP
      // =====================================================

      // feet ALWAYS below knees

      backKnee = Offset(-5, hipY + 14);
      backFoot = Offset(-10, hipY + 32);

      frontKnee = Offset(5, hipY + 14);
      frontFoot = Offset(5, hipY + 32);

      // arms slightly lifted

      backElbow = Offset(-10, armY + 8);
      backHand = Offset(-16, armY + 4);

      frontElbow = Offset(10, armY + 8);
      frontHand = Offset(16, armY + 4);

    } else if (isSliding) {

      // =====================================================
      // SLIDE
      // =====================================================

      // BOTH LEGS FORWARD
      // compact and grounded

      backKnee = Offset(14, hipY + 14);
      backFoot = Offset(26, hipY + 26);

      frontKnee = Offset(20, hipY + 14);
      frontFoot = Offset(34, hipY + 28);

      // SUPPORT ARM ON LEFT SIDE
      // NEVER under torso

      backElbow = Offset(-16, armY + 18);
      backHand = Offset(-24, size.y - 6);

      // front arm tucked inward

      frontElbow = Offset(10, armY + 8);
      frontHand = Offset(16, armY + 12);

    } else {

      // RUN

      backKnee = Offset(opposite * 0.35, hipY + 16);
      backFoot = Offset(opposite * 0.55, size.y);

      frontKnee = Offset(swing * 0.35, hipY + 16);
      frontFoot = Offset(swing * 0.55, size.y);

      backElbow = Offset(opposite * 0.45, armY + 10);
      backHand = Offset(opposite * 0.75, armY + 20);

      frontElbow = Offset(swing * 0.45, armY + 10);
      frontHand = Offset(swing * 0.75, armY + 20);
    }
    // LEGS

    canvas.drawLine(
      Offset(0, hipY),
      backKnee,
      limbPaint,
    );

    canvas.drawLine(
      backKnee,
      backFoot,
      limbPaint,
    );

    canvas.drawLine(
      Offset(0, hipY),
      frontKnee,
      limbPaint,
    );

    canvas.drawLine(
      frontKnee,
      frontFoot,
      limbPaint,
    );

    // ARMS

    canvas.drawLine(
      Offset(0, shoulderY),
      backElbow,
      limbPaint,
    );

    canvas.drawLine(
      backElbow,
      backHand,
      limbPaint,
    );

    canvas.drawCircle(
      backHand,
      3,
      handPaint,
    );

    canvas.drawLine(
      Offset(0, shoulderY),
      frontElbow,
      limbPaint,
    );

    canvas.drawLine(
      frontElbow,
      frontHand,
      limbPaint,
    );

    canvas.drawCircle(
      frontHand,
      3,
      handPaint,
    );

    canvas.restore();

    // =====================================================
    // SHADOW
    // =====================================================

    final airHeight = max(
      0,
      groundY - position.y,
    );

    final shadowScale =
        1 - (airHeight / 180).clamp(0.0, 0.45);

    if (!isSliding) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(centerX, size.y + 2),
          width: 20 * shadowScale,
          height: 6,
        ),
        Paint()
          ..color = Colors.black,
      );
    }

    // =====================================================
    // BREAK EFFECT
    // =====================================================

    if (isBreaking) {
      final glowPaint = Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          10,
        );

      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        30,
        glowPaint,
      );
    }
  }
}