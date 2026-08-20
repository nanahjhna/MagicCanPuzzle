import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart'; // 패키지 임포트
import 'game_screen.dart';
import 'tutorial_screen.dart';
import 'settings_screen.dart';
import '../widgets/ad_banner_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 버전 정보를 저장할 변수
  String _appVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    // 1. 앱이 켜지자마자 업데이트 확인 실행
    _checkForUpdate();
    // 2. 앱이 켜지자마자 버전 정보 가져오기
    _initPackageInfo();
  }

  // 버전 정보 가져오는 함수
  Future<void> _initPackageInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        // 변경: 버전 이름과 빌드 번호를 조합합니다.
        _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      });
    } catch (e) {
      debugPrint('Failed to get package info: $e');
    }
  }

  // 구글 플레이 즉시 업데이트 함수
  Future<void> _checkForUpdate() async {
    try {
      AppUpdateInfo info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        }
      }
    } catch (e) {
      debugPrint('Update check failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar를 투명하게 만들어 배경 이미지가 보이게 하고 오른쪽 상단에 버전 표시
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0, right: 16.0),
            child: Center(
              child: Text(
                'ver : $_appVersion',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7), // 배경과 대비되게 약간 투명하게
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      // AppBar 아래로 콘텐츠가 확장되도록 설정
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/title.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  _buildMenuButton(
                    context,
                    title: '게임 시작',
                    color: const Color(0xFFFB923C),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context,
                    title: '게임 방법',
                    color: const Color(0xFF34D399),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TutorialScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context,
                    title: '설정',
                    color: const Color(0xFF38BDF8),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 📌 설정 버튼 아래에 배너 광고 추가
                  const AdBannerWidget(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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