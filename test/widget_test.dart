import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:volume_fit/src/app/app_environment.dart';
import 'package:volume_fit/src/app/app_providers.dart';
import 'package:volume_fit/src/app/volume_fit_app.dart';

void main() {
  testWidgets('shows the initial Volume Fit home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: VolumeFitApp()));

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
      ProviderScope(
        overrides: [
          appEnvironmentProvider.overrideWithValue(
            AppEnvironmentConfig.parse('production'),
          ),
        ],
        child: const VolumeFitApp(),
      ),
    );

    expect(find.text('PRODUCTION'), findsNothing);
    expect(find.text('DEVELOPMENT'), findsNothing);
    expect(find.text('STAGING'), findsNothing);
  });

  testWidgets('watches appEnvironmentProvider from the UI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvironmentProvider.overrideWithValue(
            AppEnvironmentConfig.parse('staging'),
          ),
        ],
        child: const VolumeFitApp(),
      ),
    );

    expect(find.text('STAGING'), findsOneWidget);
    expect(find.text('DEVELOPMENT'), findsNothing);
  });
}
