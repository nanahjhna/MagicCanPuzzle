import 'dart:math';

class PuzzleState {
  List<List<String>> board = [
    ['window-bg', 'empty', 'window-bg', 'window-bg', 'window-bg', 'window-bg'],
    ['red', 'orange', 'yellow', 'green', 'blue', 'purple'],
    ['orange', 'yellow', 'green', 'blue', 'purple', 'red'],
    ['yellow', 'green', 'blue', 'purple', 'red', 'orange'],
  ];

  List<int> viewIndices = [0, 0, 0, 0];
  bool isSuccess = false;

  // 🔄 화면의 열(visualCol: 0~2)을 실제 데이터 배열 인덱스(0~5)로 변환
  int _toDataCol(int r, int visualCol) {
    return (viewIndices[r] + visualCol) % board[r].length;
  }

  // 🔄 실제 데이터 배열 인덱스(0~5)를 화면의 열(visualCol: 0~2)로 변환
  int _toVisualCol(int r, int actualCol) {
    return (actualCol - viewIndices[r] + board[r].length) % board[r].length;
  }

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

  // 행 회전 (버튼 눌렀을 때 실행)
  bool rotateRow(int rIdx, int direction) {
    if (rIdx == 0) return false;
    int len = board[rIdx].length;
    viewIndices[rIdx] = (viewIndices[rIdx] + direction + len) % len;
    checkSuccess();
    return true;
  }

  // 화면상의 좌표(visualR, visualC)를 입력받아 클릭 처리
  bool handleCellClick(int visualR, int visualC) {
    // 1. 터치한 위치의 실제 데이터 배열 좌표
    int dataR = visualR;
    int dataC = (visualR == 0) ? visualC : _toDataCol(visualR, visualC);

    // 이미 빈칸이거나 window-bg면 클릭 무시
    if (board[dataR][dataC] == 'empty' || board[dataR][dataC] == 'window-bg') {
      return false;
    }

    // 2. 현재 빈칸('empty')의 실제 데이터 위치 찾기
    int emptyDataR = -1;
    int emptyDataC = -1;

    for (int r = 0; r < board.length; r++) {
      for (int c = 0; c < board[r].length; c++) {
        if (board[r][c] == 'empty') {
          emptyDataR = r;
          emptyDataC = c;
          break;
        }
      }
      if (emptyDataR != -1) break;
    }

    if (emptyDataR == -1) return false;

    // 빈칸의 화면상 좌표 계산
    int emptyVisualR = emptyDataR;
    int emptyVisualC = (emptyDataR == 0) ? emptyDataC : _toVisualCol(emptyDataR, emptyDataC);

    // 3. 화면상에서 상하 또는 좌우로 1칸 인접해 있는지 확인
    bool isAdjacent = false;

    // 같은 행이고 좌우로 1칸 인접
    if (visualR == emptyVisualR && (visualC - emptyVisualC).abs() == 1) {
      isAdjacent = true;
    }
    // 같은 열이고 상하로 1칸 인접
    else if (visualC == emptyVisualC && (visualR - emptyVisualR).abs() == 1) {
      isAdjacent = true;
    }

    // 4. 인접하다면 데이터 배열의 값 교환
    if (isAdjacent) {
      String temp = board[emptyDataR][emptyDataC];
      board[emptyDataR][emptyDataC] = board[dataR][dataC];
      board[dataR][dataC] = temp;

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
        int actualIdx = _toDataCol(r, i);
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