import 'package:flutter/material.dart';

import '../game/my_game.dart';

class GameControls extends StatelessWidget {
  final MyGame game;

  const GameControls(
    this.game, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        // RUN BUTTON

        Positioned(
          left: 20,
          bottom: 20,
          child: _holdButton(
            text: "RUN",
            onHoldStart: () {
              game.isHolding = true;
            },
            onHoldEnd: () {
              game.isHolding = false;
            },
          ),
        ),

        // ACTIONS

        Positioned(
          right: 20,
          bottom: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // JUMP

              _holdButton(
                text: "JUMP",
                onHoldStart: () {
                  game.player.jumpPressed();
                },
                onHoldEnd: () {
                  game.player.jumpReleased();
                },
              ),

              const SizedBox(height: 10),

              // SLIDE

              _tapButton(
                text: "SLIDE",
                onTap: () {
                  game.player.slide();
                },
              ),

              const SizedBox(height: 10),

              // BREAK

              _tapButton(
                text: "BREAK",
                onTap: () {
                  game.player.collide();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =======================================================
  // HOLD BUTTON
  // =======================================================

  Widget _holdButton({
    required String text,
    required VoidCallback onHoldStart,
    required VoidCallback onHoldEnd,
  }) {
    return GestureDetector(
      onTapDown: (_) => onHoldStart(),
      onTapUp: (_) => onHoldEnd(),
      onTapCancel: onHoldEnd,
      child: _buttonStyle(text),
    );
  }

  // =======================================================
  // TAP BUTTON
  // =======================================================

  Widget _tapButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _buttonStyle(text),
    );
  }

  // =======================================================
  // STYLE
  // =======================================================

  Widget _buttonStyle(String text) {
    return Container(
      width: 90,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}