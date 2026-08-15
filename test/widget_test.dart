import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magiccanpuzzle/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // 빌드 및 앱 실행 확인
    await tester.pumpWidget(const MagicCanPuzzleApp());

    // 메인 화면의 타이틀 텍스트가 잘 뜨는지 확인
    expect(find.text('Cylinder Spinner Puzzle'), findsOneWidget);
  });
}