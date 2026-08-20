import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/puzzle_state.dart';

class PuzzleBoard extends StatefulWidget {
  final PuzzleState puzzleState;
  final VoidCallback onUpdate;
  final bool isSoundOn; // 1. 변수 선언

  const PuzzleBoard({
    Key? key,
    required this.puzzleState,
    required this.onUpdate,
    required this.isSoundOn // 2. 생성자에 필수값으로 추가
  }) : super(key: key);

  @override
  _PuzzleBoardState createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard> {
  // 사운드 재생을 위한 AudioPlayer 인스턴스 생성
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose(); // 위젯 종료 시 자원 해제
    super.dispose();
  }

  // puzzle_board.dart 내부
  Future<void> _playTapSound() async {
    if (!widget.isSoundOn) return; // 📌 효과음이 꺼져있으면 여기서 즉시 함수 종료 (가장 중요!)

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/tap.mp3'));
    } catch (e) { debugPrint("탭 사운드 재생 실패: $e"); }
  }

  Future<void> _playSlideSound() async {
    if (!widget.isSoundOn) return; // 📌 효과음이 꺼져있으면 즉시 종료

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/slide.mp3'));
    } catch (e) { debugPrint("슬라이드 사운드 재생 실패: $e"); }
  }

  // 색상 문자열에 따라 캐릭터 이미지 경로를 반환하는 함수
  String _getCharacterAsset(String colorName) {
    switch (colorName) {
      case 'red':
        return 'assets/images/red_char.png';
      case 'orange':
        return 'assets/images/orange_char.png';
      case 'yellow':
        return 'assets/images/yellow_char.png';
      case 'green':
        return 'assets/images/green_char.png';
      case 'blue':
        return 'assets/images/blue_char.png';
      case 'purple':
        return 'assets/images/purple_char.png';
      default:
        return '';
    }
  }

  // 입체적인 구슬 느낌을 위한 색상 변환
  Color _parseBaseColor(String colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red.shade600;
      case 'orange':
        return Colors.orange.shade600;
      case 'yellow':
        return Colors.amber.shade500;
      case 'green':
        return Colors.green.shade600;
      case 'blue':
        return Colors.blue.shade600;
      case 'purple':
        return Colors.purple.shade500;
      case 'window-bg':
        return const Color(0xFFFDE047);
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cellSize = constraints.maxWidth / 6.0;
        if (cellSize > 55) cellSize = 55;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.puzzleState.board.length, (rIdx) {
                    var row = widget.puzzleState.board[rIdx];
                    int renderCount = 3;
                    int vIdx = widget.puzzleState.viewIndices[rIdx];

                    return GestureDetector(
                      // 1. 가로 슬라이드 부분 수정
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity != null) {
                          bool rotated = false;

                          if (details.primaryVelocity! > 0) {
                            rotated = widget.puzzleState.rotateRow(rIdx, -1);
                          } else if (details.primaryVelocity! < 0) {
                            rotated = widget.puzzleState.rotateRow(rIdx, 1);
                          }

                          // 📌 실제로 회전이 성공했을 때만 슬라이드 소리 재생 및 업데이트
                          if (rotated) {
                            _playSlideSound();
                            widget.onUpdate();
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        color: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(renderCount, (i) {
                                int actualIdx = (vIdx + i) % row.length;
                                String colorStr = row[actualIdx];

                                bool isEmpty = (colorStr == 'empty');
                                bool isWindowBg = (colorStr == 'window-bg');

                                return GestureDetector(
                                  // 2. 셀(공) 탭 부분 수정
                                  onTap: () {
                                    bool moved = widget.puzzleState.handleCellClick(rIdx, actualIdx);

                                    // 📌 실제로 빈칸으로 이동했을 때만 탭 소리 재생 및 업데이트
                                    if (moved) {
                                      _playTapSound();
                                      widget.onUpdate();
                                    }
                                  },
                                  child: Container(
                                    width: cellSize,
                                    height: cellSize,
                                    margin: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: isEmpty || isWindowBg
                                          ? null
                                          : DecorationImage(
                                        image: AssetImage(_getCharacterAsset(colorStr)),
                                        fit: BoxFit.cover,
                                      ),
                                      color: isEmpty ? Colors.white : Colors.transparent,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}