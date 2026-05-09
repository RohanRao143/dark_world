import 'package:flutter/material.dart';
import 'level_select_screen.dart';
import 'profile_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "MY GAME",
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 50),

            _menuButton(context, "Play", const LevelSelectScreen()),
            _menuButton(context, "Level Select", const LevelSelectScreen()),
            _menuButton(context, "Profile", const ProfileScreen()),
            _menuButton(context, "Stats", const StatsScreen()),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext context, String title, Widget screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: 220,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            );
          },
          child: Text(title),
        ),
      ),
    );
  }
}