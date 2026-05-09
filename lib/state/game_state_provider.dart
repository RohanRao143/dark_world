// import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'game_state.dart';

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(const GameState());

  void addCoins(int value) {
    state = state.copyWith(coins: state.coins + value);
  }

  void setHighScore(int score) {
    if (score > state.highScore) {
      state = state.copyWith(highScore: score);
    }
  }

  void unlockLevel(int level) {
    if (!state.unlockedLevels.contains(level)) {
      state = state.copyWith(
        unlockedLevels: [...state.unlockedLevels, level],
      );
    }
  }

  void setCurrentLevel(int level) {
    state = state.copyWith(currentLevel: level);
  }

  /// Call when player completes a level
  void completeCurrentLevel() {
    final current = state.currentLevel;

    if (current >= GameState.maxLevel) return;

    final nextLevel = current + 1;

    final updatedUnlocked = List<int>.from(state.unlockedLevels);

    if (!updatedUnlocked.contains(nextLevel)) {
      updatedUnlocked.add(nextLevel);
    }

    state = state.copyWith(
      unlockedLevels: updatedUnlocked,
      currentLevel: nextLevel,
    );
  }

  void reset() {
    state = const GameState();
  }
}

final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState>(
  (ref) => GameStateNotifier(),
);