import 'dart:async';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    // mm:ss 형태로 타이머 포맷 변환 (예: 01:25)
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
                  // 1. 상단 정보 바 (타이머 및 설정 버튼)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 타이머 표시 (기존 점수 위치에 타이머 반영)
                      Row(
                        children: [
                          const Icon(
                            Icons.timer,
                            color: Color(0xFFFFD700),
                            size: 28,
                          ),
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
                      // 우측 상단 설정 아이콘
                      IconButton(
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          // 설정 화면 이동
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 2. 현재 게임 점수 또는 안내 문구
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
                              onUpdate: () {
                                setState(() {});
                                _checkSuccess(); // 움직일 때마다 성공 여부 체크
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

                  // 상태 표시 및 기능 버튼
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

            // ⏱️ 3초 카운트다운 오버레이 화면 (화면 중앙에 큼직하게 표시)
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

  // 하단 대기 블록 UI 컴포넌트
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