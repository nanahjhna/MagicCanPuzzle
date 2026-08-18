import 'package:flutter/material.dart';
import '../models/puzzle_state.dart';

class PuzzleBoard extends StatefulWidget {
  final PuzzleState puzzleState;
  final VoidCallback onUpdate;

  const PuzzleBoard({Key? key, required this.puzzleState, required this.onUpdate}) : super(key: key);

  @override
  _PuzzleBoardState createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard> {

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
            // 본체 캔 컨테이너
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/cola_can_background.png'),
                  fit: BoxFit.fill,
                ),
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

                    // 💡 핵심 수정: 1행(rIdx == 0)도 아래 행들과 똑같이 3개만 보이도록 수정 (원하시면 숫자를 조절하세요)
                    int renderCount = 3;
                    int vIdx = widget.puzzleState.viewIndices[rIdx];

                    // 각 행(Row)을 GestureDetector로 감싸서 좌우 슬라이드로 회전
                    return GestureDetector(
                      onHorizontalDragEnd: (details) {
                        // 1행도 슬라이드로 움직이게 하려면 rIdx != 0 조건을 빼거나 유지하세요.
                        // 만약 1행도 움직이게 하고 싶다면 rIdx != 0 조건을 지우시면 됩니다.
                        if (details.primaryVelocity != null) {
                          if (details.primaryVelocity! > 0) {
                            widget.puzzleState.rotateRow(rIdx, -1);
                            widget.onUpdate();
                          } else if (details.primaryVelocity! < 0) {
                            widget.puzzleState.rotateRow(rIdx, 1);
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
                                  onTap: () {
                                    bool moved = widget.puzzleState.handleCellClick(rIdx, actualIdx);
                                    if (moved) {
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