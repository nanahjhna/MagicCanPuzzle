import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'tutorial_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 이미지를 배경화면으로 설정
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/title.png'),
            fit: BoxFit.cover, // 화면에 꽉 차게 비율 유지하며 채우기
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 기존 텍스트 타이틀 대신 이미지가 그 역할을 하므로 빈 공간(Spacer) 또는 여백 확보
                  const Spacer(),

                  // 메뉴 버튼들 (이미지 하단부에 배치되도록 조정)
                  _buildMenuButton(
                    context,
                    title: '게임 시작',
                    color: const Color(0xFFFB923C), // 오렌지 계열
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context,
                    title: '게임 방법',
                    color: const Color(0xFF34D399), // 민트/그린 계열
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TutorialScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context,
                    title: '설정',
                    color: const Color(0xFF38BDF8), // 블루 계열
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                  const SizedBox(height: 40), // 하단 여백
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 입체적인 스타일의 커스텀 버튼 위젯
  Widget _buildMenuButton(
      BuildContext context, {
        required String title,
        required Color color,
        required VoidCallback onPressed,
      }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.black.withOpacity(0.2),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}