import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/main_screen.dart';

void main() async { // 📌 async를 추가해 주세요!
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
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