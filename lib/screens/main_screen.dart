import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'tutorial_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Cylinder Spinner Puzzle',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFDB2777)),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen())),
              child: const Text('게임 시작'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TutorialScreen())),
              child: const Text('게임 방법'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
              child: const Text('설정'),
            ),
          ],
        ),
      ),
    );
  }
}