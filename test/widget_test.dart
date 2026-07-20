import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:volume_fit/src/app/app_environment.dart';
import 'package:volume_fit/src/app/app_providers.dart';
import 'package:volume_fit/src/app/app_router.dart';
import 'package:volume_fit/src/app/volume_fit_app.dart';
import 'package:volume_fit/src/features/auth/data/auth_repository.dart';

void main() {
  testWidgets('shows the initial Volume Fit home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [isAuthenticatedProvider.overrideWithValue(true)],
        child: const VolumeFitApp(),
      ),
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
      ProviderScope(
        overrides: [
          appEnvironmentProvider.overrideWithValue(
            AppEnvironmentConfig.parse('production'),
          ),
          isAuthenticatedProvider.overrideWithValue(true),
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
          isAuthenticatedProvider.overrideWithValue(true),
        ],
        child: const VolumeFitApp(),
      ),
    );

    expect(find.text('STAGING'), findsOneWidget);
    expect(find.text('DEVELOPMENT'), findsNothing);
  });

  testWidgets('redirects unauthenticated users to login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: VolumeFitApp()));
    await tester.pumpAndSettle();

    expect(find.text('ログイン'), findsOneWidget);
    expect(find.text('メールで登録'), findsOneWidget);
    expect(find.text('筋トレ記録をAIへつなぐ'), findsNothing);
  });

  testWidgets('registers with email and moves to profile setup', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_SuccessfulAuthRepository()),
        ],
        child: const VolumeFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('emailRegistrationEmailField')),
      'new-user@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('emailRegistrationPasswordField')),
      'Password1',
    );
    await tester.tap(find.text('メールで登録'));
    await tester.pumpAndSettle();

    expect(find.text('プロフィール'), findsWidgets);
  });

  testWidgets('restores direct route access when authenticated', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isAuthenticatedProvider.overrideWithValue(true),
          initialLocationProvider.overrideWithValue(AppRoutePaths.history),
        ],
        child: const VolumeFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('履歴'), findsWidgets);
  });
}

class _SuccessfulAuthRepository implements AuthRepository {
  @override
  Future<AuthUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return AuthUser(uid: 'uid-1', email: email, emailVerified: false);
  }
}
