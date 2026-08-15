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
  Color _parseColor(String colorName) {
    switch (colorName) {
      case 'red': return Colors.red.shade500;
      case 'orange': return Colors.orange.shade500;
      case 'yellow': return Colors.amber.shade500;
      case 'green': return Colors.green.shade500;
      case 'blue': return Colors.blue.shade500;
      case 'purple': return Colors.purple.shade400;
      case 'window-bg': return const Color(0xFFFDE047);
      default: return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFBCFE8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFDB2777), width: 6),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFDE047),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFCA8A04), width: 4),
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
                    ? const SizedBox(width: 30, height: 45)
                    : IconButton(
                  icon: const Text('◀', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    widget.puzzleState.rotateRow(rIdx, -1);
                    widget.onUpdate();
                  },
                ),
                Row(
                  children: List.generate(renderCount, (i) {
                    int actualIdx = (vIdx + i) % row.length;
                    String colorStr = row[actualIdx];

                    return GestureDetector(
                      onTap: () {
                        bool moved = widget.puzzleState.handleCellClick(rIdx, actualIdx);
                        if (moved) {
                          widget.onUpdate();
                        }
                      },
                      child: Container(
                        width: 45,
                        height: 45,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _parseColor(colorStr),
                          shape: BoxShape.circle,
                          boxShadow: colorStr == 'empty' || colorStr == 'window-bg'
                              ? []
                              : [const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
                        ),
                        child: Center(
                          child: Text(
                            colorStr == 'empty' || colorStr == 'window-bg' ? '' : colorStr[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                rIdx == 0
                    ? const SizedBox(width: 30, height: 45)
                    : IconButton(
                  icon: const Text('▶', style: TextStyle(fontWeight: FontWeight.bold)),
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
    );
  }
}