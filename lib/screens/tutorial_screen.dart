import 'package:flutter/material.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 핵심 변경: 배경이 AppBar 영역 뒤까지 확장되도록 설정 (상태바까지 덮음)
      extendBodyBehindAppBar: true,
      // MainScreen과 동일한 배경 이미지 적용
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'), // 동일한 배경 이미지 사용
            fit: BoxFit.cover, // 화면에 꽉 차게 비율 유지하며 채우기
          ),
        ),
        child: Column(
          children: [
            // 커스텀 상단 영역 (배경 위에 반투명하게 겹침)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // 뒤로가기 버튼 대신 홈 화면으로 가는 버튼 배치
                    IconButton(
                      icon: const Icon(Icons.home, color: Colors.white),
                      onPressed: () {
                        // 홈 화면(루트 경로)으로 이동
                        // 현재 화면 위에 있는 모든 경로를 pop하여 제거
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      tooltip: '홈으로 이동',
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '게임 방법',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // 레이아웃 균형을 위한 빈 공간 (IconButton 크기와 동일)
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            // 기존 콘텐츠 영역 (중앙 배치)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),

                      // 게임 방법 내용을 담는 반투명 카드 컨테이너
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4), // 반투명 검은색 배경
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.help_outline,
                              size: 48,
                              color: Color(0xFF34D399), // 민트/그린 포인트 컬러
                            ),
                            SizedBox(height: 16),
                            Text(
                              '게임 플레이 방법',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              '양옆의 화살표 버튼을 눌러 실린더 행을 회전시키고 공 색상을 일치시키세요!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                height: 1.5, // 줄간격 조정
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}