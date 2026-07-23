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
}

class FakeWorkoutSetInputRepository implements WorkoutSetInputRepository {
  FakeWorkoutSetInputRepository({
    this.failure,
    this.result = WorkoutSetSaveResult.saved,
  });

  WorkoutSetInputFailure? failure;
  WorkoutSetSaveResult result;
  int saveCallCount = 0;
  WorkoutSetDraft? lastDraft;

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
}
