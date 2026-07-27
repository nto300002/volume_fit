import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/app/app_providers.dart';
import 'package:volume_fit/src/features/workout/data/workout_plan_repository.dart';

void main() {
  test('saves next workout plan as separated planned values', () async {
    final writer = FakeWorkoutPlanWriter();
    final now = DateTime.utc(2026, 7, 27, 1, 2, 3);
    final plannedDate = DateTime.utc(2026, 7, 30);
    final container = ProviderContainer(
      overrides: [
        currentWorkoutPlanAuthUserIdProvider.overrideWithValue('uid-1'),
        workoutPlanWriterProvider.overrideWithValue(writer),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(workoutPlanRepositoryProvider)
        .savePlan(
          WorkoutPlanDraft(
            plannedDate: plannedDate,
            exerciseId: 'bench_press',
            exerciseName: 'ベンチプレス',
            resistanceType: 'external_weight',
            plannedLoadKg: 60,
            plannedReps: 10,
            plannedSetCount: 3,
            targetRir: 2,
            memo: '胸の日',
            sourceAiExportHistoryId: 'ai-history-1',
          ),
        );

    expect(writer.ownerUserId, 'uid-1');
    final data = writer.data;
    expect(data?['schemaVersion'], 1);
    expect(data?['ownerUserId'], 'uid-1');
    expect(data?['status'], 'planned');
    expect(data?['plannedDate'], plannedDate);
    expect(data?['sourceAiExportHistoryId'], 'ai-history-1');
    expect(data?['actualSessionId'], isNull);
    expect(data?['createdAt'], now);
    expect(data?['updatedAt'], now);
    expect(data?['isDeleted'], isFalse);

    final planned = data?['plannedValues'] as Map<String, Object?>;
    expect(planned['exerciseId'], 'bench_press');
    expect(planned['exerciseName'], 'ベンチプレス');
    expect(planned['resistanceType'], 'external_weight');
    expect(planned['loadKg'], 60);
    expect(planned['reps'], 10);
    expect(planned['setCount'], 3);
    expect(planned['targetRir'], 2);
    expect(planned['memo'], '胸の日');

    expect(data?['actualValues'], isNull);
  });

  test('rejects save when auth user is missing', () async {
    final container = ProviderContainer(
      overrides: [
        currentWorkoutPlanAuthUserIdProvider.overrideWithValue(null),
        workoutPlanWriterProvider.overrideWithValue(FakeWorkoutPlanWriter()),
      ],
    );
    addTearDown(container.dispose);

    expect(
      () => container
          .read(workoutPlanRepositoryProvider)
          .savePlan(
            WorkoutPlanDraft(
              plannedDate: DateTime.utc(2026, 7, 30),
              exerciseId: 'bench_press',
              exerciseName: 'ベンチプレス',
              resistanceType: 'external_weight',
              plannedLoadKg: 60,
              plannedReps: 10,
              plannedSetCount: 3,
              targetRir: 2,
            ),
          ),
      throwsA(isA<WorkoutPlanFailure>()),
    );
  });
}

class FakeWorkoutPlanWriter implements WorkoutPlanWriter {
  String? ownerUserId;
  Map<String, Object?>? data;

  @override
  Future<void> addPlan({
    required String ownerUserId,
    required Map<String, Object?> data,
  }) async {
    this.ownerUserId = ownerUserId;
    this.data = data;
  }
}
