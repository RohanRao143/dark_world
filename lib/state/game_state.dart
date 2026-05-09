class GameState {
  final int currentLevel;
  final int coins;
  final int highScore;
  final List<int> unlockedLevels;

  static const int maxLevel = 10;

  const GameState({
    this.currentLevel = 1,
    this.coins = 0,
    this.highScore = 0,
    this.unlockedLevels = const [1],
  });

  bool isUnlockedLevel(int level) {
    return unlockedLevels.contains(level);
  }

  GameState copyWith({
    int? currentLevel,
    int? coins,
    int? highScore,
    List<int>? unlockedLevels,
  }) {
    return GameState(
      currentLevel: currentLevel ?? this.currentLevel,
      coins: coins ?? this.coins,
      highScore: highScore ?? this.highScore,
      unlockedLevels: unlockedLevels ?? this.unlockedLevels,
    );
  }
}