import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/puzzle_state.dart';
import '../widgets/puzzle_board.dart';
import '../widgets/ad_banner_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey<PuzzleBoardState> _boardKey = GlobalKey<PuzzleBoardState>();

  final PuzzleState _puzzleState = PuzzleState();

  // ⏱️ 타이머 및 게임 상태 관련 변수 (밀리초 단위 측정을 위해 int 밀리초로 변경)
  Timer? _gameTimer;
  int _millisecondsElapsed = 0;
  bool _isPlaying = false;
  bool _isCountdownActive = false;
  int _countdownValue = 3;

  // ⚙️ 설정 상태 변수 (기본값 설정)
  bool _isSoundOn = true;
  bool _isBgmOn = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // 화면에 진입하자마자 시작 팝업 띄우기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showStartPopup();
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  // 📌 SharedPreferences를 이용해 설정 불러오기
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSoundOn = prefs.getBool('isSoundOn') ?? true;
      _isBgmOn = prefs.getBool('isBgmOn') ?? true;
    });
  }

  // 📌 설정 변경 시 SharedPreferences에 저장하기
  Future<void> _saveSettings(bool soundOn, bool bgmOn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSoundOn', soundOn);
    await prefs.setBool('isBgmOn', bgmOn);
  }

  // 1️⃣ 게임 시작 전 안내 팝업 및 3초 카운트다운
  void _showStartPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: const Color(0xFF283593),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text(
              '🎮 퍼즐 게임',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              '준비되셨나요?\n확인을 누르면 3초 후 게임이 시작됩니다!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            // _showStartPopup 함수 안의 actions 부분 수정

            actionsAlignment: MainAxisAlignment.center,
            actions: [
              // 📌 ElevatedButton 대신 GestureDetector를 사용하여 누르는 순간 반응하게 변경
              GestureDetector(
                onTapDown: (_) {
                  // 🚀 손가락을 대는 순간 바로 실행되는 코드
                  Navigator.pop(context); // 팝업 닫기
                  _startCountdown();       // 카운트다운 및 시작 소리 재생
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '게임 시작',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 2️⃣ 3초 카운트다운 로직
  void _startCountdown() {
    setState(() {
      _isCountdownActive = true;
      _countdownValue = 3;
      // 💡 타이머는 아직 시작하지 않고 일시정지 상태로 둡니다.
      _isPlaying = false;
    });

    // 🚀 바로 이 순간! 카운트다운이 시작되자마자 시작 소리 재생
    _boardKey.currentState?.playStartSound();

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownValue > 1) {
        setState(() {
          _countdownValue--;
        });
      } else {
        timer.cancel();
        // 📌 카운트다운이 완전히 끝난 바로 이 순간!
        setState(() {
          _isCountdownActive = false;
          _isPlaying = true;
          _millisecondsElapsed = 0; // 시간이 0부터 정확히 시작되도록 초기화
        });
        _startTimer(); // 🚀 타이머 시작!
      }
    });
  }

  // 3️⃣ 정밀 타이머 시작 (10ms 단위로 갱신하여 밀리초 표시)
  void _startTimer() {
    if (!_isPlaying) return;
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      setState(() {
        _millisecondsElapsed += 10;
      });
    });
  }

  // 4️⃣ 게임 성공 시 호출
  void _checkSuccess() {
    if (_puzzleState.isSuccess && _isPlaying) {
      _gameTimer?.cancel();
      _isPlaying = false;

      // 🎉 2. 퍼즐을 클리어했을 때 클리어 소리 재생!
      _boardKey.currentState?.playClearSound();

      _showSuccessPopup();
    }
  }

  // 5️⃣ 성공 팝업 (밀리초가 포함된 기록 표시)
  void _showSuccessPopup() {
    int totalSeconds = _millisecondsElapsed ~/ 1000;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    int centiseconds = (_millisecondsElapsed % 1000) ~/ 10; // 1/100초 단위

    String timeStr = minutes > 0
        ? '$minutes분 $seconds.${centiseconds.toString().padLeft(2, '0')}초'
        : '$seconds.${centiseconds.toString().padLeft(2, '0')}초';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF283593),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            '🎉 성공!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '소요 시간: $timeStr',
                  style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // 팝업 닫기
                      Navigator.pop(context); // 홈으로 이동
                    },
                    icon: const Icon(Icons.home, color: Colors.white),
                    label: const Text('홈으로', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _millisecondsElapsed = 0;
                        _puzzleState.shuffle();
                        _startCountdown();
                      });
                    },
                    child: const Text('다시 하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ⚙️ 설정 팝업 (열릴 때 타이머 일시정지, 닫힐 때 타이머 재개)
  void _showSettingsDialog(BuildContext context) {
    // 설정창이 열리는 순간 타이머 일시정지
    if (_isPlaying) {
      _gameTimer?.cancel();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF283593),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                '⚙️ 설정',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. 홈으로 이동 항목
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.home, color: Colors.white, size: 22),
                            SizedBox(width: 10),
                            Text(
                              '메인으로 이동',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context); // 팝업 닫기
                            Navigator.pop(context); // 홈으로 나가기
                          },
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white12,
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 20),

                    // 2. 다시하기 항목
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.refresh, color: Colors.amber, size: 22),
                            SizedBox(width: 10),
                            Text(
                              '게임 다시하기',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context); // 팝업 닫기 후 아래 .then()에서 타이머가 재개되므로 수동 처리 필요
                            setState(() {
                              _millisecondsElapsed = 0;
                              _puzzleState.shuffle();
                              _startCountdown(); // 다시 시작
                            });
                          },
                          icon: const Icon(Icons.play_arrow, color: Colors.black, size: 18),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 30),

                    // 3. 효과음 스위치
                    _buildSettingSwitch(
                      title: '효과음',
                      value: _isSoundOn,
                      onChanged: (value) {
                        setDialogState(() {
                          _isSoundOn = value;
                        });
                        setState(() {});
                        _saveSettings(_isSoundOn, _isBgmOn);
                      },
                    ),
                    const Divider(color: Colors.white24, height: 24),

                    // 4. BGM 스위치
                    _buildSettingSwitch(
                      title: 'BGM (배경음악)',
                      value: _isBgmOn,
                      onChanged: (value) {
                        setDialogState(() {
                          _isBgmOn = value;
                        });
                        setState(() {});
                        _saveSettings(_isSoundOn, _isBgmOn);
                      },
                    ),
                    const Divider(color: Colors.white24, height: 24),

                    // 5. 개인정보처리방침 버튼
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '개인정보처리방침',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // 📌 설정창이 완전히 닫힐 때 게임 중이었다면 타이머 재개
      if (_isPlaying) {
        _startTimer();
      }
    });
  }

  Widget _buildSettingSwitch({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.amber,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // ⏱️ 시간 포맷팅: mm:ss.SS (분:초.밀리초 단위 표시)
    int totalSeconds = _millisecondsElapsed ~/ 1000;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    int centiseconds = (_millisecondsElapsed % 1000) ~/ 10;

    String formattedTime = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${centiseconds.toString().padLeft(2, '0')}';

    // GameScreen의 build 메서드 내부 return 부분 수정
    return Scaffold(
      backgroundColor: const Color(0xFF3B4CCA),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                children: [
                  // 1. 상단 정보 바
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer, color: Color(0xFFFFD700), size: 28),
                          const SizedBox(width: 6),
                          Text(
                            formattedTime,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                        onPressed: () => _showSettingsDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 3. 중앙 게임 보드 영역 (Flexible로 변경하여 공간 부족 시 줄어들게 처리)
                  Flexible(
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 350, maxHeight: 350),
                        decoration: BoxDecoration(
                          color: const Color(0xFF283593),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: PuzzleBoard(
                              key: _boardKey,
                              puzzleState: _puzzleState,
                              isSoundOn: _isSoundOn,
                              onUpdate: () {
                                setState(() {});
                                _checkSuccess();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 📌 배너 광고가 잘리지 않도록 고정 크기 영역 확보
                  const SizedBox(
                    height: 50,
                    child: AdBannerWidget(),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),

            if (_isCountdownActive)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Text(
                    '$_countdownValue',
                    style: const TextStyle(
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewBlock({required Color color, required String shapeType}) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: const Color(0xFF263280),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Center(
        child: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIPreviewBlock() {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: const Color(0xFF263280),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Center(
        child: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.cyan,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}