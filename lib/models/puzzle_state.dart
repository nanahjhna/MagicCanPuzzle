import 'dart:math';

class PuzzleState {
  List<List<String>> board = [
    ['window-bg', 'empty', 'window-bg'],
    ['red', 'orange', 'yellow', 'green', 'blue', 'purple'],
    ['orange', 'yellow', 'green', 'blue', 'purple', 'red'],
    ['yellow', 'green', 'blue', 'purple', 'red', 'orange'],
  ];

  List<int> viewIndices = [0, 0, 0, 0];
  bool isSuccess = false;

  void shuffle() {
    final random = Random();
    for (int r = 1; r < board.length; r++) {
      viewIndices[r] = random.nextInt(board[r].length);
      for (int i = board[r].length - 1; i > 0; i--) {
        int j = random.nextInt(i + 1);
        String temp = board[r][i];
        board[r][i] = board[r][j];
        board[r][j] = temp;
      }
    }
    checkSuccess();
  }

  void rotateRow(int rIdx, int direction) {
    if (rIdx == 0) return;
    int len = board[rIdx].length;
    viewIndices[rIdx] = (viewIndices[rIdx] + direction + len) % len;
    checkSuccess();
  }

  // 특정 위치를 클릭했을 때 빈칸과 인접해 있다면 이동
  bool handleCellClick(int clickedR, int clickedC) {
    // 1. 현재 빈칸(empty)의 실제 위치(r, c) 찾기
    int emptyR = -1;
    int emptyC = -1;

    for (int r = 0; r < board.length; r++) {
      for (int c = 0; c < board[r].length; c++) {
        if (board[r][c] == 'empty') {
          emptyR = r;
          emptyC = c;
          break;
        }
      }
      if (emptyR != -1) break;
    }

    if (emptyR == -1) return false;

    // 클릭한 곳이 이미 빈칸이거나 window-bg면 무시
    if (board[clickedR][clickedC] == 'empty' || board[clickedR][clickedC] == 'window-bg') {
      return false;
    }

    // 2. 인접 여부 확인 후 이동
    bool isAdjacent = false;

    if ((clickedR - emptyR).abs() == 1) {
      if (clickedR == 0 || emptyR == 0) {
        if (clickedR == 0) {
          int v2Idx = viewIndices[1];
          int targetColIn2 = (v2Idx + clickedC) % 6;
          if (emptyR == 1 && emptyC == targetColIn2) {
            isAdjacent = true;
          }
        } else {
          int v2Idx = viewIndices[1];
          int clickedViewColIn2 = (clickedC - v2Idx + 6) % 6;
          if (emptyR == 0 && emptyC == clickedViewColIn2) {
            isAdjacent = true;
          }
        }
      } else {
        int clickedViewCol = -1;
        int c_vIdx = viewIndices[clickedR];
        for (int k = 0; k < 3; k++) {
          if ((c_vIdx + k) % board[clickedR].length == clickedC) {
            clickedViewCol = k;
            break;
          }
        }

        int emptyViewCol = -1;
        int e_vIdx = viewIndices[emptyR];
        for (int k = 0; k < 3; k++) {
          if ((e_vIdx + k) % board[emptyR].length == emptyC) {
            emptyViewCol = k;
            break;
          }
        }

        if (clickedViewCol != -1 && emptyViewCol != -1 && clickedViewCol == emptyViewCol) {
          isAdjacent = true;
        }
      }
    }

    if (isAdjacent) {
      board[emptyR][emptyC] = board[clickedR][clickedC];
      board[clickedR][clickedC] = 'empty';
      checkSuccess();
      return true;
    }

    return false;
  }

  void checkSuccess() {
    bool allMatch = true;
    for (int i = 0; i < 6; i++) {
      List<String> colColors = [];
      for (int r = 1; r < board.length; r++) {
        int actualIdx = (viewIndices[r] + i) % board[r].length;
        colColors.add(board[r][actualIdx]);
      }
      if (colColors.contains('empty') || !colColors.every((val) => val == colColors[0])) {
        allMatch = false;
        break;
      }
    }
    isSuccess = allMatch;
  }
}