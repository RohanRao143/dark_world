import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/my_game.dart';
import '../logic/game_controls.dart';

class GameWrapper extends StatelessWidget {
  const GameWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final game = MyGame();

    return Scaffold(
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'Controls': (context, game) => GameControls(game as MyGame),
        },
        initialActiveOverlays: const ['Controls'],
      ),
    );
  }
}