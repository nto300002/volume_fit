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

    expect(find.text('ログイン'), findsWidgets);
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

  testWidgets('logs in with email and moves to profile setup', (
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
      'user@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('emailRegistrationPasswordField')),
      'Password1',
    );
    await tester.tap(find.text('メールでログイン'));
    await tester.pumpAndSettle();

    expect(find.text('プロフィール'), findsWidgets);
  });

  testWidgets('logs in with Google and moves to profile setup', (
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

    await tester.tap(find.text('Googleでログイン'));
    await tester.pumpAndSettle();

    expect(find.text('プロフィール'), findsWidgets);
  });

  testWidgets('shows an error when Google login fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            _FailingAuthRepository(const AuthFailure('Googleログインに失敗しました')),
          ),
        ],
        child: const VolumeFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Googleでログイン'));
    await tester.pumpAndSettle();

    expect(find.text('Googleログインに失敗しました'), findsOneWidget);
    expect(find.text('プロフィール'), findsNothing);
  });

  testWidgets('shows an error when email login fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            _FailingAuthRepository(
              const AuthFailure('メールアドレスまたはパスワードが正しくありません'),
            ),
          ),
        ],
        child: const VolumeFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('emailRegistrationEmailField')),
      'user@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('emailRegistrationPasswordField')),
      'wrong-password',
    );
    await tester.tap(find.text('メールでログイン'));
    await tester.pumpAndSettle();

    expect(find.text('メールアドレスまたはパスワードが正しくありません'), findsOneWidget);
    expect(find.text('プロフィール'), findsNothing);
  });

  testWidgets('sends password reset email from the login screen', (
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
      'user@example.com',
    );
    await tester.tap(find.text('パスワード再設定'));
    await tester.pumpAndSettle();

    expect(find.text('パスワード再設定メールを送信しました'), findsOneWidget);
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

  @override
  Future<AuthUser> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return AuthUser(uid: 'uid-1', email: email, emailVerified: false);
  }

  @override
  Future<AuthUser> loginWithGoogle() async {
    return const AuthUser(
      uid: 'google-uid-1',
      email: 'user@example.com',
      emailVerified: true,
    );
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {}
}

class _FailingAuthRepository implements AuthRepository {
  const _FailingAuthRepository(this.failure);

  final AuthFailure failure;

  @override
  Future<AuthUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw failure;
  }

  @override
  Future<AuthUser> loginWithGoogle() async {
    throw failure;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    throw failure;
  }
}
