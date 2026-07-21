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
        .saveSet(exerciseId: 'push_up', repsText: '12', rir: 2);

    expect(succeeded, isTrue);
    expect(repository.saveCallCount, 1);
    expect(repository.lastDraft?.exerciseId, 'push_up');
    expect(repository.lastDraft?.reps, 12);
    expect(repository.lastDraft?.rir, 2);
    expect(
      container.read(workoutSetInputControllerProvider).value?.isSaved,
      isTrue,
    );
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
        .saveSet(exerciseId: 'push_up', repsText: '15', rir: 1);

    final state = container.read(workoutSetInputControllerProvider).value;
    expect(succeeded, isFalse);
    expect(repository.saveCallCount, 1);
    expect(state?.errorMessage, '保存に失敗しました');
    expect(state?.draft.exerciseId, 'push_up');
    expect(state?.draft.repsText, '15');
    expect(state?.draft.rir, 1);
  });
}

class FakeWorkoutSetInputRepository implements WorkoutSetInputRepository {
  FakeWorkoutSetInputRepository({this.failure});

  final WorkoutSetInputFailure? failure;
  int saveCallCount = 0;
  WorkoutSetDraft? lastDraft;

  @override
  Future<void> saveDraftSet(WorkoutSetDraft draft) async {
    saveCallCount += 1;
    lastDraft = draft;

    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
  }
}
