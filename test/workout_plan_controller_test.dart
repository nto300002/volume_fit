import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/workout/application/workout_plan_controller.dart';
import 'package:volume_fit/src/features/workout/data/workout_plan_repository.dart';

void main() {
  test('rejects missing planned date before saving', () async {
    final repository = FakeWorkoutPlanRepository();
    final container = ProviderContainer(
      overrides: [workoutPlanRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(workoutPlanControllerProvider.notifier)
        .savePlan(
          plannedDateText: '',
          exerciseId: 'bench_press',
          exerciseName: 'ベンチプレス',
          resistanceType: 'external_weight',
          loadText: '60',
          repsText: '10',
          setCountText: '3',
          targetRir: 2,
        );

    final state = container.read(workoutPlanControllerProvider).value;
    expect(succeeded, isFalse);
    expect(repository.saveCallCount, 0);
    expect(state?.errorMessage, '予定日を入力してください');
  });

  test('saves next workout plan', () async {
    final repository = FakeWorkoutPlanRepository();
    final container = ProviderContainer(
      overrides: [workoutPlanRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(workoutPlanControllerProvider.notifier)
        .savePlan(
          plannedDateText: '2026-07-30',
          exerciseId: 'bench_press',
          exerciseName: 'ベンチプレス',
          resistanceType: 'external_weight',
          loadText: '60',
          repsText: '10',
          setCountText: '3',
          targetRir: 2,
          memo: '胸の日',
          sourceAiExportHistoryId: 'ai-history-1',
        );

    final state = container.read(workoutPlanControllerProvider).value;
    expect(succeeded, isTrue);
    expect(state?.isSaved, isTrue);
    expect(repository.lastDraft?.plannedDate, DateTime.utc(2026, 7, 30));
    expect(repository.lastDraft?.plannedLoadKg, 60);
    expect(repository.lastDraft?.plannedReps, 10);
    expect(repository.lastDraft?.plannedSetCount, 3);
    expect(repository.lastDraft?.targetRir, 2);
    expect(repository.lastDraft?.sourceAiExportHistoryId, 'ai-history-1');
  });
}

class FakeWorkoutPlanRepository implements WorkoutPlanRepository {
  int saveCallCount = 0;
  WorkoutPlanDraft? lastDraft;

  @override
  Future<void> savePlan(WorkoutPlanDraft draft) async {
    saveCallCount += 1;
    lastDraft = draft;
  }
}
