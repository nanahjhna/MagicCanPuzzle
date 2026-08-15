import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정'), backgroundColor: const Color(0xFFDB2777)),
      body: const Center(child: Text('효과음 및 BGM 설정 화면입니다.')),
    );
  }
}