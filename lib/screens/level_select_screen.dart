import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/game_state_provider.dart';
import '../state/game_state.dart';
import '../widgets/game_wrapper.dart';

class LevelSelectScreen extends ConsumerWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Level Select")),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: GameState.maxLevel,
        itemBuilder: (context, index) {
          final level = index + 1;
          final isUnlocked = gameState.isUnlockedLevel(level);

          return ElevatedButton(
            onPressed: isUnlocked
                ? () {
                    ref
                        .read(gameStateProvider.notifier)
                        .setCurrentLevel(level);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GameWrapper(level: level),
                      ),
                    );
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isUnlocked ? Colors.blue : Colors.grey,
            ),
            child: Text(
              isUnlocked ? "Level $level" : "Locked",
            ),
          );
        },
      ),
    );
  }
}