import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MagicCanPuzzleApp());
}

class MagicCanPuzzleApp extends StatelessWidget {
  const MagicCanPuzzleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magic Can Puzzle',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}