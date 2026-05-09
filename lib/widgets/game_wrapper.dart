import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/my_game.dart';
import '../logic/game_controls.dart';

class GameWrapper extends ConsumerWidget {
  final int level;

  const GameWrapper({
    super.key,
    required this.level,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = MyGame(
      ref: ref,
      level: level,
    );

    return Scaffold(
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'Controls': (context, game) =>
              GameControls(game as MyGame),
        },
        initialActiveOverlays: const ['Controls'],
      ),
    );
  }
}