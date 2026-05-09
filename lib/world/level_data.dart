import 'world_theme.dart';

class LevelData {
  final int level;
  final WorldTheme theme;

  const LevelData({
    required this.level,
    required this.theme,
  });
}

// TODO:: Add more worlds

final levels = <LevelData>[
  const LevelData(
    level: 1,
    theme: WorldTheme.industrial,
  ),

  const LevelData(
    level: 2,
    theme: WorldTheme.forest,
  ),
];