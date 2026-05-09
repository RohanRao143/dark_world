import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stats")),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Games Played: 0"),
            SizedBox(height: 10),
            Text("Best Score: 0"),
            SizedBox(height: 10),
            Text("Enemies Defeated: 0"),
          ],
        ),
      ),
    );
  }
}