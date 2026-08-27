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
  PuzzleBoardState createState() => PuzzleBoardState();
}

class PuzzleBoardState extends State<PuzzleBoard> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> playStartSound() async {
    if (!widget.isSoundOn) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/start.mp3'));
    } catch (e) {
      debugPrint("시작 사운드 재생 실패: $e");
    }
  }

  Future<void> playClearSound() async {
    if (!widget.isSoundOn) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/clear.mp3'));
    } catch (e) {
      debugPrint("클리어 사운드 재생 실패: $e");
    }
  }

  Future<void> _playTapSound() async {
    if (!widget.isSoundOn) return;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('sounds/tap.mp3'));
    } catch (e) { debugPrint("탭 사운드 재생 실패: $e"); }
  }

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
        if (cellSize > 48) cellSize = 48;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
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
                    bool isRotatable = (rIdx != 0); // 0번 행은 회전 불가

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ◀ 왼쪽 이동 버튼 (0번 행은 빈 공간)
                          SizedBox(
                            width: 30,
                            height: cellSize,
                            child: isRotatable
                                ? IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.arrow_left, color: Colors.amber, size: 28),
                              onPressed: () {
                                bool rotated = widget.puzzleState.rotateRow(rIdx, -1);
                                if (rotated) {
                                  _playSlideSound();
                                  widget.onUpdate();
                                }
                              },
                            )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 4),

                          // 중앙 퍼즐 블록들
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(renderCount, (visualCol) {
                              int actualIdx = (vIdx + visualCol) % row.length;
                              String colorStr = row[actualIdx];

                              bool isEmpty = (colorStr == 'empty');
                              bool isWindowBg = (colorStr == 'window-bg');

                              return GestureDetector(
                                onTap: () {
                                  bool moved = widget.puzzleState.handleCellClick(rIdx, visualCol);
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
                          const SizedBox(width: 4),

                          // ▶ 오른쪽 이동 버튼
                          SizedBox(
                            width: 30,
                            height: cellSize,
                            child: isRotatable
                                ? IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.arrow_right, color: Colors.amber, size: 28),
                              onPressed: () {
                                bool rotated = widget.puzzleState.rotateRow(rIdx, 1);
                                if (rotated) {
                                  _playSlideSound();
                                  widget.onUpdate();
                                }
                              },
                            )
                                : const SizedBox.shrink(),
                          ),
                        ],
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