import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/workout/application/workout_set_input_controller.dart';
import 'package:volume_fit/src/features/workout/data/workout_set_input_repository.dart';

void main() {
  test('rejects missing exercise before saving', () async {
    final repository = FakeWorkoutSetInputRepository();
    final container = ProviderContainer(
      overrides: [
        workoutSetInputRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(workoutSetInputControllerProvider.notifier)
        .saveSet(repsText: '12', rir: 2);

    expect(succeeded, isFalse);
    expect(repository.saveCallCount, 0);
    expect(
      container.read(workoutSetInputControllerProvider).value?.errorMessage,
      '種目を選択してください',
    );
  });

  test('rejects invalid reps before saving', () async {
    final repository = FakeWorkoutSetInputRepository();
    final container = ProviderContainer(
      overrides: [
        workoutSetInputRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(workoutSetInputControllerProvider.notifier)
        .saveSet(exerciseId: 'push_up', repsText: '0', rir: 2);

    expect(succeeded, isFalse);
    expect(repository.saveCallCount, 0);
    expect(
      container.read(workoutSetInputControllerProvider).value?.errorMessage,
      '回数は1回以上で入力してください',
    );
  });

  test('saves a push-up set with reps and RIR', () async {
    final repository = FakeWorkoutSetInputRepository();
    final container = ProviderContainer(
      overrides: [
        workoutSetInputRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(workoutSetInputControllerProvider.notifier)
        .saveSet(
          exerciseId: 'push_up',
          bodyWeightText: '80',
          bodyWeightLoadRatio: 0.72,
          repsText: '12',
          rir: 2,
        );

    expect(succeeded, isTrue);
    expect(repository.saveCallCount, 1);
    expect(repository.lastDraft?.exerciseId, 'push_up');
    expect(repository.lastDraft?.bodyWeightKg, 80);
    expect(repository.lastDraft?.bodyWeightLoadRatio, 0.72);
    expect(repository.lastDraft?.reps, 12);
    expect(repository.lastDraft?.rir, 2);
    expect(
      container.read(workoutSetInputControllerProvider).value?.saveStatus,
      WorkoutSetSaveStatus.saved,
    );
  });

  test('saves an external-weight set without bodyweight load ratio', () async {
    final repository = FakeWorkoutSetInputRepository();
    final container = ProviderContainer(
      overrides: [
        workoutSetInputRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(workoutSetInputControllerProvider.notifier)
        .saveSet(
          exerciseId: 'bench_press',
          externalWeightText: '60',
          repsText: '10',
          rir: 2,
        );

    expect(succeeded, isTrue);
    expect(repository.saveCallCount, 1);
    expect(repository.lastDraft?.exerciseId, 'bench_press');
    expect(repository.lastDraft?.externalWeightKg, 60);
    expect(repository.lastDraft?.bodyWeightKg, isNull);
    expect(repository.lastDraft?.bodyWeightLoadRatio, isNull);
    expect(repository.lastDraft?.reps, 10);
    expect(repository.lastDraft?.rir, 2);
  });

  test('saves a dumbbell set as total external load', () async {
    final repository = FakeWorkoutSetInputRepository();
    final container = ProviderContainer(
      overrides: [
        workoutSetInputRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(workoutSetInputControllerProvider.notifier)
        .saveSet(
          exerciseId: 'dumbbell_curl',
          externalWeightText: '22.5',
          externalLoadCountText: '2',
          repsText: '8',
          rir: 1,
        );

    expect(succeeded, isTrue);
    expect(repository.lastDraft?.externalWeightKg, 45);
    expect(
      container.read(workoutSetInputControllerProvider).value?.sessionVolumeKg,
      0,
    );
  });

  test('adds an external-weight set and aggregates session volume', () async {
    final repository = FakeWorkoutSetInputRepository();
    final container = ProviderContainer(
      overrides: [
        workoutSetInputRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final added = container
        .read(workoutSetInputControllerProvider.notifier)
        .addSet(
          exerciseId: 'bench_press',
          externalWeightText: '60',
          repsText: '10',
          rir: 2,
        );

    final state = container.read(workoutSetInputControllerProvider).value;
    expect(added, isTrue);
    expect(state?.sets.single.externalWeightKg, 60);
    expect(state?.sessionVolumeKg, 600);
  });

  test('rejects invalid external weight before saving', () async {
    final repository = FakeWorkoutSetInputRepository();
    final container = ProviderContainer(
      overrides: [
        workoutSetInputRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(workoutSetInputControllerProvider.notifier)
        .saveSet(
          exerciseId: 'bench_press',
          externalWeightText: '0',
          repsText: '10',
          rir: 2,
        );

    expect(succeeded, isFalse);
    expect(repository.saveCallCount, 0);
    expect(
      container.read(workoutSetInputControllerProvider).value?.errorMessage,
      '重量は0より大きい値で入力してください',
    );
  });

  test('shows pending status after a queued save', () async {
    final repository = FakeWorkoutSetInputRepository(
      result: WorkoutSetSaveResult.pending,
    );
    final container = ProviderContainer(
      overrides: [
        workoutSetInputRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(workoutSetInputControllerProvider.notifier)
        .saveSet(
          exerciseId: 'push_up',
          bodyWeightText: '80',
          bodyWeightLoadRatio: 0.72,
          repsText: '12',
          rir: 2,
        );

    final state = container.read(workoutSetInputControllerProvider).value;
    expect(succeeded, isTrue);
    expect(state?.saveStatus, WorkoutSetSaveStatus.pending);
    expect(state?.statusMessage, '同期待ちです');
  });

  test('shows offline pending status after an offline queued save', () async {
    final repository = FakeWorkoutSetInputRepository(
      result: WorkoutSetSaveResult.offlinePending,
    );
    final container = ProviderContainer(
      overrides: [
        workoutSetInputRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(workoutSetInputControllerProvider.notifier)
        .saveSet(
          exerciseId: 'push_up',
          bodyWeightText: '80',
          bodyWeightLoadRatio: 0.72,
          repsText: '12',
          rir: 2,
        );

    final state = container.read(workoutSetInputControllerProvider).value;
    expect(succeeded, isTrue);
    expect(state?.saveStatus, WorkoutSetSaveStatus.offlinePending);
    expect(state?.statusMessage, 'オフライン保留中です');
  });

  test('keeps the latest input when saving fails', () async {
    final repository = FakeWorkoutSetInputRepository(
      failure: const WorkoutSetInputFailure('保存に失敗しました'),
    );
    final container = ProviderContainer(
      overrides: [
        workoutSetInputRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(workoutSetInputControllerProvider.notifier)
        .saveSet(
          exerciseId: 'push_up',
          bodyWeightText: '80',
          bodyWeightLoadRatio: 0.72,
          repsText: '15',
          rir: 1,
        );

    final state = container.read(workoutSetInputControllerProvider).value;
    expect(succeeded, isFalse);
    expect(repository.saveCallCount, 1);
    expect(state?.saveStatus, WorkoutSetSaveStatus.failed);
    expect(state?.errorMessage, '保存に失敗しました');
    expect(state?.draft.exerciseId, 'push_up');
    expect(state?.draft.bodyWeightText, '80');
    expect(state?.draft.repsText, '15');
    expect(state?.draft.rir, 1);
  });

  test('retries the latest failed save', () async {
    final repository = FakeWorkoutSetInputRepository(
      failure: const WorkoutSetInputFailure('保存に失敗しました'),
    );
    final container = ProviderContainer(
      overrides: [
        workoutSetInputRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(workoutSetInputControllerProvider.notifier)
        .saveSet(
          exerciseId: 'push_up',
          bodyWeightText: '80',
          bodyWeightLoadRatio: 0.72,
          repsText: '15',
          rir: 1,
        );

    repository.failure = null;
    final succeeded = await container
        .read(workoutSetInputControllerProvider.notifier)
        .retrySave();

    final state = container.read(workoutSetInputControllerProvider).value;
    expect(succeeded, isTrue);
    expect(repository.saveCallCount, 2);
    expect(repository.lastDraft?.reps, 15);
    expect(state?.saveStatus, WorkoutSetSaveStatus.saved);
  });

  test('adds multiple sets and aggregates session volume', () async {
    final repository = FakeWorkoutSetInputRepository();
    final container = ProviderContainer(
      overrides: [
        workoutSetInputRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      workoutSetInputControllerProvider.notifier,
    );

    final firstAdded = controller.addSet(
      exerciseId: 'push_up',
      bodyWeightText: '80',
      bodyWeightLoadRatio: 0.72,
      repsText: '12',
      rir: 2,
    );
    final secondAdded = controller.addSet(
      exerciseId: 'push_up',
      bodyWeightText: '80',
      bodyWeightLoadRatio: 0.72,
      repsText: '10',
      rir: 3,
    );

    final state = container.read(workoutSetInputControllerProvider).value;
    expect(firstAdded, isTrue);
    expect(secondAdded, isTrue);
    expect(state?.sets.map((set) => set.order), [1, 2]);
    expect(state?.sets.map((set) => set.reps), [12, 10]);
    expect(state?.sessionVolumeKg, closeTo(1267.2, 0.001));
  });

  test('edits an added set while keeping order', () async {
    final repository = FakeWorkoutSetInputRepository();
    final container = ProviderContainer(
      overrides: [
        workoutSetInputRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      workoutSetInputControllerProvider.notifier,
    );
    controller
      ..addSet(
        exerciseId: 'push_up',
        bodyWeightText: '80',
        bodyWeightLoadRatio: 0.72,
        repsText: '12',
        rir: 2,
      )
      ..addSet(
        exerciseId: 'push_up',
        bodyWeightText: '80',
        bodyWeightLoadRatio: 0.72,
        repsText: '10',
        rir: 3,
      );

    final edited = controller.updateSet(
      order: 2,
      exerciseId: 'push_up',
      bodyWeightText: '80',
      bodyWeightLoadRatio: 0.72,
      repsText: '8',
      rir: 1,
    );

    final state = container.read(workoutSetInputControllerProvider).value;
    expect(edited, isTrue);
    expect(state?.sets.map((set) => set.order), [1, 2]);
    expect(state?.sets.map((set) => set.reps), [12, 8]);
    expect(state?.sets.last.rir, 1);
  });

  test('duplicates the latest set with a new order', () async {
    final repository = FakeWorkoutSetInputRepository();
    final container = ProviderContainer(
      overrides: [
        workoutSetInputRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      workoutSetInputControllerProvider.notifier,
    );
    controller.addSet(
      exerciseId: 'push_up',
      bodyWeightText: '80',
      bodyWeightLoadRatio: 0.72,
      addedWeightText: '5',
      assistanceWeightText: '2',
      repsText: '12',
      rir: 2,
    );

    final duplicated = controller.duplicateLatestSet();

    final state = container.read(workoutSetInputControllerProvider).value;
    expect(duplicated, isTrue);
    expect(state?.sets.map((set) => set.order), [1, 2]);
    expect(state?.sets.map((set) => set.reps), [12, 12]);
    expect(state?.sets.map((set) => set.rir), [2, 2]);
    expect(state?.sets.last.bodyWeightKg, 80);
    expect(state?.sets.last.bodyWeightLoadRatio, 0.72);
    expect(state?.sets.last.externalWeightKg, isNull);
    expect(state?.sets.last.addedWeightKg, 5);
    expect(state?.sets.last.assistanceWeightKg, 2);
  });

  test('does not duplicate when no set exists', () async {
    final repository = FakeWorkoutSetInputRepository();
    final container = ProviderContainer(
      overrides: [
        workoutSetInputRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final duplicated = container
        .read(workoutSetInputControllerProvider.notifier)
        .duplicateLatestSet();

    final state = container.read(workoutSetInputControllerProvider).value;
    expect(duplicated, isFalse);
    expect(state?.sets, isEmpty);
    expect(state?.errorMessage, '複製できるセットがありません');
  });

  test('saves added sets as one session draft', () async {
    final repository = FakeWorkoutSetInputRepository();
    final container = ProviderContainer(
      overrides: [
        workoutSetInputRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(
      workoutSetInputControllerProvider.notifier,
    );
    controller
      ..addSet(
        exerciseId: 'push_up',
        bodyWeightText: '80',
        bodyWeightLoadRatio: 0.72,
        repsText: '12',
        rir: 2,
      )
      ..addSet(
        exerciseId: 'push_up',
        bodyWeightText: '80',
        bodyWeightLoadRatio: 0.72,
        repsText: '10',
        rir: 3,
      );

    final succeeded = await controller.saveSession();

    expect(succeeded, isTrue);
    expect(repository.saveSessionCallCount, 1);
    expect(repository.lastSessionDraft?.sets.map((set) => set.order), [1, 2]);
    expect(repository.lastSessionDraft?.sets.map((set) => set.reps), [12, 10]);
  });
}

class FakeWorkoutSetInputRepository implements WorkoutSetInputRepository {
  FakeWorkoutSetInputRepository({
    this.failure,
    this.result = WorkoutSetSaveResult.saved,
  });

  WorkoutSetInputFailure? failure;
  WorkoutSetSaveResult result;
  int saveCallCount = 0;
  int saveSessionCallCount = 0;
  WorkoutSetDraft? lastDraft;
  WorkoutSessionDraft? lastSessionDraft;

  @override
  Future<WorkoutSetSaveResult> saveDraftSet(WorkoutSetDraft draft) async {
    saveCallCount += 1;
    lastDraft = draft;

    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }

    return result;
  }

  @override
  Future<WorkoutSetSaveResult> saveSession(WorkoutSessionDraft draft) async {
    saveSessionCallCount += 1;
    lastSessionDraft = draft;

    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }

    return result;
  }
}
