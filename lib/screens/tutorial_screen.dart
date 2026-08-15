import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('게임 방법'), backgroundColor: const Color(0xFFDB2777)),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text('양옆의 화살표 버튼을 눌러 실린더 행을 회전시키고 공 색상을 일치시키세요!'),
      ),
    );
  }
}