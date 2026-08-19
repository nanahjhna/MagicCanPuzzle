import 'package:flutter/material.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({Key? key}) : super(key: key);

  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  // PageView의 현재 페이지 상태를 관리하는 컨트롤러
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 튜토리얼 데이터 리스트 (제목, 설명, 이미지 경로)
  final List<Map<String, String>> _tutorialData = [
    {
      'title': '1. 게임 목표',
      'text': '세로 줄(Column)의 공 색상을 모두 동일하게 맞추면 승리합니다!',
      'image': 'assets/images/tutorial_goal.png' // 생성된 이미지 경로
    },
    {
      'title': '2. 실린더 회전',
      'text': '각 행을 좌우로 드래그하거나 화살표 버튼을 눌러 회전시킬 수 있습니다.',
      'image': 'assets/images/tutorial_rotate.png' // 생성된 이미지 경로
    },
    {
      'title': '3. 구슬 이동',
      'text': '빈칸(Empty)과 인접한 구슬을 탭하면 빈칸으로 이동합니다.',
      'image': 'assets/images/tutorial_tap.png' // 생성된 이미지 경로
    },
  ];

  @override
  void dispose() {
    _pageController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        // 배경 이미지가 SafeArea까지 확장되도록 Container 설정
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. 커스텀 상단 영역 (홈 버튼 + 타이틀)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.home, color: Colors.white),
                      onPressed: () {
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
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    // 레이아웃 균형을 위한 빈 공간
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // 2. 튜토리얼 콘텐츠 영역 (이미지 슬라이더 + 텍스트)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      // 🖼️ 이미지 슬라이더 (PageView)
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _tutorialData.length,
                          onPageChanged: (int page) {
                            setState(() {
                              _currentPage = page;
                            });
                          },
                          itemBuilder: (context, index) {
                            return _buildTutorialPage(_tutorialData[index]);
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔵 페이지 인디케이터 (점 3개)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _tutorialData.length,
                              (index) => _buildPageIndicatorDot(index == _currentPage),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 💡 개별 튜토리얼 페이지 위젯 생성 함수
  Widget _buildTutorialPage(Map<String, String> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 이미지를 담는 컨테이너 (반투명 카드 스타일)
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5), // 더 진한 반투명 배경
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              // 💡 핵심: 이미지 삽입
              child: Image.asset(
                data['image']!,
                fit: BoxFit.contain, // 이미지 비율 유지하며 카드 안에 꽉 채우기
                // 이미지가 로드되지 않았을 때 에러 처리
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.grey, size: 64),
                  );
                },
                // 로딩 중 표시
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return frame != null ? child : const Center(child: CircularProgressIndicator(color: Colors.amberAccent,));
                },
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 📝 텍스트 설명 (반투명 배경)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  data['title']!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.amberAccent, // 제목 강조
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data['text']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.6, // 줄간격 조정으로 가독성 향상
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔵 개별 인디케이터 점 생성 함수
  Widget _buildPageIndicatorDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      height: 10,
      width: isActive ? 20 : 10, // 활성화된 점은 길게
      decoration: BoxDecoration(
        color: isActive ? Colors.amberAccent : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}