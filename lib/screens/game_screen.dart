import 'package:flutter/material.dart';
import '../models/puzzle_state.dart';
import '../widgets/puzzle_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final PuzzleState _puzzleState = PuzzleState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        title: const Text('Puzzle Game'),
        backgroundColor: const Color(0xFFDB2777),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PuzzleBoard(
              puzzleState: _puzzleState,
              onUpdate: () => setState(() {}),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDB2777)),
              onPressed: () {
                setState(() {
                  _puzzleState.shuffle();
                });
              },
              child: const Text('🔀 공 섞기 (Shuffle)', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 15),
            Text(
              _puzzleState.isSuccess ? '🎉 성공!' : '❌ 맞추는 중...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _puzzleState.isSuccess ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}