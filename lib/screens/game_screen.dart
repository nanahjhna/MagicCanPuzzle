import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 📌 1. 패키지 임포트
import '../models/puzzle_state.dart';
import '../widgets/puzzle_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final PuzzleState _puzzleState = PuzzleState();

  // ⏱️ 타이머 및 게임 상태 관련 변수
  Timer? _gameTimer;
  int _secondsElapsed = 0;
  bool _isPlaying = false;
  bool _isCountdownActive = false;
  int _countdownValue = 3;

  // ⚙️ 설정 상태 변수 (기본값 설정)
  bool _isSoundOn = true;
  bool _isBgmOn = true;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // 📌 2. 앱 실행 시 저장된 설정 불러오기

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

  // 📌 3. SharedPreferences를 이용해 설정 불러오기
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isSoundOn = prefs.getBool('isSoundOn') ?? true;
      _isBgmOn = prefs.getBool('isBgmOn') ?? true;
    });
  }

  // 📌 4. 설정 변경 시 SharedPreferences에 저장하기
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
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _startCountdown();
                },
                child: const Text('게임 시작', style: TextStyle(fontWeight: FontWeight.bold)),
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
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownValue > 1) {
        setState(() {
          _countdownValue--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isCountdownActive = false;
          _secondsElapsed = 0;
          _isPlaying = true; // 게임 플레이 중 상태 활성화
        });
        _startTimer(); // 게임 타이머 시작
      }
    });
  }

  // 3️⃣ 실시간 타이머 시작
  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  // 4️⃣ 게임 성공 시 호출
  void _checkSuccess() {
    if (_puzzleState.isSuccess && _isPlaying) {
      _gameTimer?.cancel();
      _isPlaying = false;
      _showSuccessPopup();
    }
  }

  // 5️⃣ 성공 팝업 (기록 표시)
  void _showSuccessPopup() {
    int minutes = _secondsElapsed ~/ 60;
    int seconds = _secondsElapsed % 60;
    String timeStr = minutes > 0 ? '$minutes분 $seconds초' : '$seconds초';

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
              const Text(
                '퍼즐을 완성했습니다!',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 15),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _puzzleState.shuffle();
                  _startCountdown(); // 다시 시작
                });
              },
              child: const Text('다시 하기', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // ⚙️ 설정 팝업을 띄우는 함수
  void _showSettingsDialog(BuildContext context) {
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
                    // 1. 효과음 스위치
                    _buildSettingSwitch(
                      title: '효과음',
                      value: _isSoundOn,
                      onChanged: (value) {
                        setDialogState(() {
                          _isSoundOn = value;
                        });
                        setState(() {});
                        _saveSettings(_isSoundOn, _isBgmOn); // 변경 즉시 저장
                      },
                    ),
                    const Divider(color: Colors.white24, height: 24),

                    // 2. BGM 스위치
                    _buildSettingSwitch(
                      title: 'BGM (배경음악)',
                      value: _isBgmOn,
                      onChanged: (value) {
                        setDialogState(() {
                          _isBgmOn = value;
                        });
                        setState(() {});
                        _saveSettings(_isSoundOn, _isBgmOn); // 변경 즉시 저장
                      },
                    ),
                    const Divider(color: Colors.white24, height: 24),

                    // 3. 개인정보처리방침 버튼
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          // TODO: 개인정보처리방침 링크 연결
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '개인정보처리방침',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white70,
                              size: 14,
                            ),
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('닫기', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 스위치 항목을 만들어주는 헬퍼 메서드
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
    String formattedTime = '${(_secondsElapsed ~/ 60).toString().padLeft(2, '0')}:${(_secondsElapsed % 60).toString().padLeft(2, '0')}';

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
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
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

                  const Text(
                    'PUZZLE',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white70,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. 중앙 게임 보드 영역
                  Expanded(
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
                              puzzleState: _puzzleState,
                              isSoundOn: _isSoundOn, // 📌 이 줄이 없으면 PuzzleBoard는 효과음이 켜져있는지 꺼져있는지 모릅니다!
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
                  const SizedBox(height: 20),

                  // 4. 하단 블록 선택 영역
                  Container(
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFF323FAD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPreviewBlock(color: Colors.purpleAccent, shapeType: 'T'),
                        _buildPreviewBlock(color: Colors.amber, shapeType: 'Square'),
                        _buildPreviewBlock(color: Colors.cyan, shapeType: 'I'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _puzzleState.isSuccess ? '🎉 성공!' : '슬라이드하여 움직여보세요!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _puzzleState.isSuccess ? Colors.greenAccent : Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 20),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _puzzleState.shuffle();
                            _startCountdown();
                          });
                        },
                        icon: const Icon(Icons.refresh, color: Colors.amber),
                        label: const Text('새로고침', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
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
}