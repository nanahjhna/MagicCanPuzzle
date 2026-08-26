import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/puzzle_state.dart';

class PuzzleBoard extends StatefulWidget {
  final PuzzleState puzzleState;
  final VoidCallback onUpdate;
  final bool isSoundOn;

  const PuzzleBoard({
    Key? key,
    required this.puzzleState,
    required this.onUpdate,
    required this.isSoundOn,
  }) : super(key: key);

  @override
  // 📌 부모 위젯에서 key를 통해 메서드에 접근할 수 있도록 public으로 변경 (_PuzzleBoardState -> PuzzleBoardState)
  PuzzleBoardState createState() => PuzzleBoardState();
}

// 밑줄(_)을 없애서 외부에서 접근 가능한 State 클래스로 만듭니다.
class PuzzleBoardState extends State<PuzzleBoard> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // 📌 1. 시작 소리 재생 메서드 (시작 버튼을 누를 때 호출됨)
  Future<void> playStartSound() async {
    if (!widget.isSoundOn) return;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/start.mp3'));
    } catch (e) {
      debugPrint("시작 사운드 재생 실패: $e");
    }
  }

  // 📌 2. 클리어 소리 재생 메서드 (클리어 감지 시 호출됨)
  Future<void> playClearSound() async {
    if (!widget.isSoundOn) return;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/clear.mp3'));
    } catch (e) {
      debugPrint("클리어 사운드 재생 실패: $e");
    }
  }

  // 탭 소리 재생
  Future<void> _playTapSound() async {
    if (!widget.isSoundOn) return;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/tap.mp3'));
    } catch (e) { debugPrint("탭 사운드 재생 실패: $e"); }
  }

  // 슬라이드 소리 재생
  Future<void> _playSlideSound() async {
    if (!widget.isSoundOn) return;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/slide.mp3'));
    } catch (e) { debugPrint("슬라이드 사운드 재생 실패: $e"); }
  }

  String _getCharacterAsset(String colorName) {
    switch (colorName) {
      case 'red': return 'assets/images/red_char.png';
      case 'orange': return 'assets/images/orange_char.png';
      case 'yellow': return 'assets/images/yellow_char.png';
      case 'green': return 'assets/images/green_char.png';
      case 'blue': return 'assets/images/blue_char.png';
      case 'purple': return 'assets/images/purple_char.png';
      default: return '';
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
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity != null) {
                          bool rotated = false;

                          if (details.primaryVelocity! > 0) {
                            rotated = widget.puzzleState.rotateRow(rIdx, -1);
                          } else if (details.primaryVelocity! < 0) {
                            rotated = widget.puzzleState.rotateRow(rIdx, -1); // 혹은 1
                          }

                          if (rotated) {
                            _playSlideSound();
                            widget.onUpdate(); // 여기서 부모 위젯의 상태 갱신 및 클리어 검사 실행됨
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
                                  onTap: () {
                                    bool moved = widget.puzzleState.handleCellClick(rIdx, actualIdx);

                                    if (moved) {
                                      _playTapSound();
                                      widget.onUpdate(); // 여기서 부모 위젯의 상태 갱신 및 클리어 검사 실행됨
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