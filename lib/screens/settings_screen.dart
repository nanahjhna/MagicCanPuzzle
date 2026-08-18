import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 예시용 설정 상태값
  bool _isSoundOn = true;
  bool _isBgmOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 배경이 AppBar 영역 뒤까지 확장되도록 설정 (상태바까지 덮음)
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
                    // 홈 화면으로 바로 이동하는 버튼
                    IconButton(
                      icon: const Icon(Icons.home, color: Colors.white),
                      onPressed: () {
                        // 현재 화면 위에 쌓인 모든 경로를 pop하여 루트(홈) 화면으로 이동
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      tooltip: '홈으로 이동',
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '설정',
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

                      // 설정 항목들을 감싸는 카드 컨테이너 (가독성 향상)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4), // 반투명 검은색 배경으로 텍스트 가독성 확보
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            _buildSettingSwitch(
                              title: '효과음',
                              value: _isSoundOn,
                              onChanged: (value) {
                                setState(() {
                                  _isSoundOn = value;
                                });
                              },
                            ),
                            const Divider(color: Colors.white24, height: 24),
                            _buildSettingSwitch(
                              title: 'BGM (배경음악)',
                              value: _isBgmOn,
                              onChanged: (value) {
                                setState(() {
                                  _isBgmOn = value;
                                });
                              },
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

  // 설정 스위치 항목을 만드는 헬퍼 위젯
  Widget _buildSettingSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF38BDF8), // MainScreen의 설정 버튼 블루 컬러와 통일감 부여
        ),
      ],
    );
  }
}