import 'package:flutter_test/flutter_test.dart';

import 'package:volume_fit/src/app/app_environment.dart';
import 'package:volume_fit/src/app/volume_fit_app.dart';

void main() {
  testWidgets('shows the initial Volume Fit home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      VolumeFitApp(environment: AppEnvironmentConfig.parse('development')),
    );

    expect(find.text('Volume Fit'), findsOneWidget);
    expect(find.text('筋トレ記録をAIへつなぐ'), findsOneWidget);
    expect(find.text('トレーニングを開始'), findsOneWidget);
    expect(find.text('ログインして始める'), findsOneWidget);
    expect(find.text('DEVELOPMENT'), findsOneWidget);

    expect(find.text('Flutter Demo Home Page'), findsNothing);
  });

  testWidgets('hides environment label in production', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      VolumeFitApp(environment: AppEnvironmentConfig.parse('production')),
    );

    expect(find.text('PRODUCTION'), findsNothing);
    expect(find.text('DEVELOPMENT'), findsNothing);
    expect(find.text('STAGING'), findsNothing);
  });
}
