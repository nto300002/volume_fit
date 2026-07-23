import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:volume_fit/src/app/app_environment.dart';
import 'package:volume_fit/src/app/app_providers.dart';
import 'package:volume_fit/src/app/app_router.dart';
import 'package:volume_fit/src/app/volume_fit_app.dart';
import 'package:volume_fit/src/features/ai_export/data/ai_export_history_repository.dart';
import 'package:volume_fit/src/features/auth/data/auth_repository.dart';
import 'package:volume_fit/src/features/profile/data/profile_repository.dart';
import 'package:volume_fit/src/features/workout/data/calculation_settings.dart';
import 'package:volume_fit/src/features/workout/data/workout_set_input_repository.dart';

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

  testWidgets('logs out and returns to the login screen', (
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

    await tester.tap(find.text('ログアウト'));
    await tester.pumpAndSettle();

    expect(find.text('メールでログイン'), findsOneWidget);
    expect(find.text('筋トレ記録をAIへつなぐ'), findsNothing);
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

  testWidgets('saves initial profile and moves to home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isAuthenticatedProvider.overrideWithValue(true),
          initialLocationProvider.overrideWithValue(AppRoutePaths.profile),
          profileRepositoryProvider.overrideWithValue(
            _SuccessfulProfileRepository(),
          ),
        ],
        child: const VolumeFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('初回プロフィール設定'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('profileBodyWeightField')),
      '66.8',
    );
    await tester.tap(find.byKey(const Key('profileGoalDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('筋肥大').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('保存する'));
    await tester.pumpAndSettle();

    expect(find.text('筋トレ記録をAIへつなぐ'), findsOneWidget);
  });

  testWidgets('opens workout input from home and saves one push-up set', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isAuthenticatedProvider.overrideWithValue(true),
          workoutSetInputRepositoryProvider.overrideWithValue(
            _SuccessfulWorkoutSetInputRepository(),
          ),
        ],
        child: const VolumeFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    await _saveOnePushUpSet(tester);

    expect(find.text('保存済みです'), findsOneWidget);
  });

  testWidgets('generates AI markdown preview from one push-up set', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [isAuthenticatedProvider.overrideWithValue(true)],
        child: const VolumeFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('AI出力を作成'));
    await tester.pumpAndSettle();

    expect(find.text('AI出力'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('aiBodyWeightField')), '80');
    await tester.enterText(find.byKey(const Key('aiRepsField')), '12');
    await tester.tap(find.byKey(const Key('aiRirDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('RIR 2').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('aiGenerateMarkdownButton')));
    await tester.pumpAndSettle();

    expect(find.text('Markdownプレビュー'), findsOneWidget);
    expect(find.textContaining('記録上確認できる事実と推定を分けてください。'), findsOneWidget);
    expect(find.textContaining('アプリの計算値は比較用の概算です。'), findsOneWidget);
    expect(
      find.textContaining('最後にNotionへ保存しやすいMarkdownを出力してください。'),
      findsOneWidget,
    );
    expect(
      find.textContaining('| 1 | 12 | 2 | 80.0 kg | 0.72 |'),
      findsOneWidget,
    );
    expect(
      find.textContaining('| 1 | 57.6 kg | 691.2 kg | 656.6 kg | ハードセット |'),
      findsOneWidget,
    );
  });

  testWidgets('saves generated AI markdown history', (
    WidgetTester tester,
  ) async {
    final repository = _SuccessfulAiExportHistoryRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isAuthenticatedProvider.overrideWithValue(true),
          aiExportHistoryRepositoryProvider.overrideWithValue(repository),
        ],
        child: const VolumeFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('AI出力を作成'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('aiBodyWeightField')), '80');
    await tester.enterText(find.byKey(const Key('aiRepsField')), '12');
    await tester.tap(find.byKey(const Key('aiRirDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('RIR 2').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('aiGenerateMarkdownButton')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('aiSaveHistoryButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('aiSaveHistoryButton')));
    await tester.pumpAndSettle();

    expect(find.text('AI出力履歴を保存しました'), findsOneWidget);
    expect(repository.saveCallCount, 1);
    expect(repository.lastDraft?.markdownContent, contains('# AIトレーニングレビュー依頼'));
    expect(repository.lastDraft?.calculationVersion, 'standard-v1');
    expect(repository.lastDraft?.promptVersion, 'prompt-v1');
    final snapshot = repository.lastDraft?.calculationSnapshot;
    final sets = snapshot?['sets'] as List<Object?>;
    final set = sets.single as Map<String, Object?>;
    expect(set['estimatedLoadKg'], closeTo(57.6, 0.001));
  });

  testWidgets('shows pending save status', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isAuthenticatedProvider.overrideWithValue(true),
          workoutSetInputRepositoryProvider.overrideWithValue(
            _ResultWorkoutSetInputRepository(WorkoutSetSaveResult.pending),
          ),
        ],
        child: const VolumeFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    await _saveOnePushUpSet(tester);

    expect(find.text('同期待ちです'), findsOneWidget);
  });

  testWidgets('shows offline pending save status', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isAuthenticatedProvider.overrideWithValue(true),
          workoutSetInputRepositoryProvider.overrideWithValue(
            _ResultWorkoutSetInputRepository(
              WorkoutSetSaveResult.offlinePending,
            ),
          ),
        ],
        child: const VolumeFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    await _saveOnePushUpSet(tester);

    expect(find.text('オフライン保留中です'), findsOneWidget);
  });

  testWidgets('shows failed save status and retry action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isAuthenticatedProvider.overrideWithValue(true),
          workoutSetInputRepositoryProvider.overrideWithValue(
            _FailingWorkoutSetInputRepository(),
          ),
        ],
        child: const VolumeFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    await _saveOnePushUpSet(tester);

    expect(find.text('保存に失敗しました'), findsOneWidget);
    expect(find.text('再試行'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('shows approximate bodyweight load using calculation settings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isAuthenticatedProvider.overrideWithValue(true),
          calculationSettingsProvider.overrideWithValue(
            const CalculationSettings(bodyWeightLoadRatios: {'push_up': 0.72}),
          ),
        ],
        child: const VolumeFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('トレーニングを開始'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('workoutExerciseDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('腕立て伏せ').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('workoutBodyWeightField')),
      '80',
    );
    await tester.pumpAndSettle();

    expect(find.text('推定負荷（概算）'), findsOneWidget);
    expect(find.text('57.6 kg'), findsOneWidget);
  });

  testWidgets('shows approximate set volume when reps and load are entered', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isAuthenticatedProvider.overrideWithValue(true),
          calculationSettingsProvider.overrideWithValue(
            const CalculationSettings(bodyWeightLoadRatios: {'push_up': 0.72}),
          ),
        ],
        child: const VolumeFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('トレーニングを開始'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('workoutExerciseDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('腕立て伏せ').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('workoutBodyWeightField')),
      '80',
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('workoutRepsField')), '12');
    await tester.pumpAndSettle();

    expect(find.text('セットボリューム（概算）'), findsOneWidget);
    expect(find.text('691.2 kg'), findsOneWidget);
  });

  testWidgets('shows RIR adjusted volume as a comparison rule', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isAuthenticatedProvider.overrideWithValue(true),
          calculationSettingsProvider.overrideWithValue(
            const CalculationSettings(bodyWeightLoadRatios: {'push_up': 0.72}),
          ),
        ],
        child: const VolumeFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('トレーニングを開始'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('workoutExerciseDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('腕立て伏せ').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('workoutBodyWeightField')),
      '80',
    );
    await tester.enterText(find.byKey(const Key('workoutRepsField')), '12');
    await tester.tap(find.byKey(const Key('workoutRirDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('RIR 2').last);
    await tester.pumpAndSettle();

    expect(find.text('RIR補正ボリューム（比較用）'), findsOneWidget);
    expect(find.text('656.6 kg'), findsOneWidget);
    expect(find.text('独自比較ルールによる概算値です'), findsOneWidget);
  });

  testWidgets('shows hard set judgment when RIR is selected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isAuthenticatedProvider.overrideWithValue(true),
          calculationSettingsProvider.overrideWithValue(
            const CalculationSettings(bodyWeightLoadRatios: {'push_up': 0.72}),
          ),
        ],
        child: const VolumeFitApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('トレーニングを開始'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('workoutExerciseDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('腕立て伏せ').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('workoutRirDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('RIR 4').last);
    await tester.pumpAndSettle();

    expect(find.text('ハードセット判定'), findsOneWidget);
    expect(find.text('ハードセット'), findsOneWidget);
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

  @override
  Future<void> signOut() async {}
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

  @override
  Future<void> signOut() async {
    throw failure;
  }
}

class _SuccessfulProfileRepository implements ProfileRepository {
  @override
  Future<void> saveInitialProfile(InitialProfileDraft draft) async {}
}

class _SuccessfulWorkoutSetInputRepository
    implements WorkoutSetInputRepository {
  @override
  Future<WorkoutSetSaveResult> saveDraftSet(WorkoutSetDraft draft) async {
    return WorkoutSetSaveResult.saved;
  }
}

class _ResultWorkoutSetInputRepository implements WorkoutSetInputRepository {
  const _ResultWorkoutSetInputRepository(this.result);

  final WorkoutSetSaveResult result;

  @override
  Future<WorkoutSetSaveResult> saveDraftSet(WorkoutSetDraft draft) async {
    return result;
  }
}

class _FailingWorkoutSetInputRepository implements WorkoutSetInputRepository {
  @override
  Future<WorkoutSetSaveResult> saveDraftSet(WorkoutSetDraft draft) async {
    throw const WorkoutSetInputFailure('保存に失敗しました');
  }
}

class _SuccessfulAiExportHistoryRepository
    implements AiExportHistoryRepository {
  int saveCallCount = 0;
  AiExportHistoryDraft? lastDraft;

  @override
  Future<void> saveHistory(AiExportHistoryDraft draft) async {
    saveCallCount += 1;
    lastDraft = draft;
  }
}

Future<void> _saveOnePushUpSet(WidgetTester tester) async {
  await tester.tap(find.text('トレーニングを開始'));
  await tester.pumpAndSettle();

  expect(find.text('セット入力'), findsOneWidget);

  await tester.tap(find.byKey(const Key('workoutExerciseDropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('腕立て伏せ').last);
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('workoutBodyWeightField')), '80');
  await tester.enterText(find.byKey(const Key('workoutRepsField')), '12');
  await tester.tap(find.byKey(const Key('workoutRirDropdown')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('RIR 2').last);
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('保存'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('保存'));
  await tester.pumpAndSettle();
}
