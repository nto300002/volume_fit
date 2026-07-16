import 'package:flutter_test/flutter_test.dart';

import 'package:volume_fit/main.dart';

void main() {
  testWidgets('shows the initial Volume Fit home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Volume Fit'), findsOneWidget);
    expect(find.text('筋トレ記録をAIへつなぐ'), findsOneWidget);
    expect(find.text('トレーニングを開始'), findsOneWidget);
    expect(find.text('ログインして始める'), findsOneWidget);

    expect(find.text('Flutter Demo Home Page'), findsNothing);
  });
}
