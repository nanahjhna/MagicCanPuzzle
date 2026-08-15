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

  // 1. 색상 문자열에 따라 캐릭터 이미지 경로를 반환하는 함수
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

  // 입체적인 구슬 느낌을 위한 색상 변환 (RadialGradient용 베이스 컬러)
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
    // 💡 화면 크기에 맞게 동적으로 크기를 조절하기 위해 LayoutBuilder로 감쌉니다.
    return LayoutBuilder(
      builder: (context, constraints) {
        // 스마트폰 가로 폭에 맞춰 셀 크기를 자동 계산 (너무 커지지 않게 최대 55 제한)
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
                    int renderCount = (rIdx == 0) ? row.length : 3;
                    int vIdx = widget.puzzleState.viewIndices[rIdx];

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        rIdx == 0
                            ? SizedBox(width: cellSize * 0.8, height: cellSize)
                            : IconButton(
                          // 💡 fontSize를 추가하여 화살표 크기를 키웁니다.
                          icon: Text(
                            '◀',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF881337),
                              fontSize: cellSize * 0.6, // 셀 크기에 비례해서 화살표 키우기 (또는 고정값 예: 24.0)
                            ),
                          ),
                          onPressed: () {
                            widget.puzzleState.rotateRow(rIdx, -1);
                            widget.onUpdate();
                          },
                        ),
                        Row(
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
                                // 💡 고정값(55) 대신 계산된 반응형 크기(cellSize) 적용
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
                        rIdx == 0
                            ? SizedBox(width: cellSize * 0.8, height: cellSize)
                            : IconButton(
                          icon: Text(
                            '▶',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF881337),
                              fontSize: cellSize * 0.6, // 크기 조절
                            ),
                          ),
                          onPressed: () {
                            widget.puzzleState.rotateRow(rIdx, 1);
                            widget.onUpdate();
                          },
                        ),
                      ],
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