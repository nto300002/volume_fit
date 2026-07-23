import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/app/app_providers.dart';
import 'package:volume_fit/src/features/workout/data/workout_set_input_repository.dart';

void main() {
  test('saves a push-up set as a WorkoutSession payload', () async {
    final writer = FakeWorkoutSessionWriter();
    final now = DateTime.utc(2026, 7, 23, 1, 2, 3);
    final container = ProviderContainer(
      overrides: [
        currentAuthUserIdProvider.overrideWithValue('uid-1'),
        workoutSessionWriterProvider.overrideWithValue(writer),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(workoutSetInputRepositoryProvider)
        .saveDraftSet(
          const WorkoutSetDraft(
            exerciseId: 'push_up',
            bodyWeightKg: 80,
            bodyWeightLoadRatio: 0.72,
            addedWeightKg: 0,
            assistanceWeightKg: 0,
            reps: 12,
            rir: 2,
          ),
        );

    expect(writer.ownerUserId, 'uid-1');
    final data = writer.data;
    expect(data?['schemaVersion'], 1);
    expect(data?['ownerUserId'], 'uid-1');
    expect(data?['status'], 'completed');
    expect(data?['exerciseIds'], ['push_up']);
    expect(data?['startedAt'], now);
    expect(data?['completedAt'], now);
    expect(data?['createdAt'], now);
    expect(data?['updatedAt'], now);
    expect(data?['isDeleted'], isFalse);

    final condition = data?['condition'] as Map<String, Object?>;
    expect(condition['bodyWeightKg'], 80);

    final exercises = data?['exercises'] as List<Object?>;
    final exercise = exercises.single as Map<String, Object?>;
    expect(exercise['exerciseId'], 'push_up');
    expect(exercise['displayName'], '腕立て伏せ');
    expect(exercise['resistanceType'], 'body_weight');
    expect(exercise['variation'], 'standard');

    final sets = exercise['sets'] as List<Object?>;
    final set = sets.single as Map<String, Object?>;
    expect(set['order'], 1);
    expect(set['externalWeightKg'], isNull);
    expect(set['bodyWeightKg'], 80);
    expect(set['bodyWeightLoadRatio'], 0.72);
    expect(set['addedWeightKg'], 0);
    expect(set['assistanceWeightKg'], 0);
    expect(set['reps'], 12);
    expect(set['rir'], 2);
    expect(set['result'], 'completed');
    expect(set.containsKey('estimatedLoadKg'), isFalse);
    expect(set.containsKey('setVolumeKg'), isFalse);
    expect(set.containsKey('effortAdjustedVolume'), isFalse);
  });

  test('rejects save when auth user is missing', () async {
    final container = ProviderContainer(
      overrides: [
        currentAuthUserIdProvider.overrideWithValue(null),
        workoutSessionWriterProvider.overrideWithValue(
          FakeWorkoutSessionWriter(),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      () => container
          .read(workoutSetInputRepositoryProvider)
          .saveDraftSet(
            const WorkoutSetDraft(
              exerciseId: 'push_up',
              bodyWeightKg: 80,
              bodyWeightLoadRatio: 0.72,
              addedWeightKg: 0,
              assistanceWeightKg: 0,
              reps: 12,
              rir: 2,
            ),
          ),
      throwsA(isA<WorkoutSetInputFailure>()),
    );
  });
}

class FakeWorkoutSessionWriter implements WorkoutSessionWriter {
  String? ownerUserId;
  Map<String, Object?>? data;

  @override
  Future<void> addSession({
    required String ownerUserId,
    required Map<String, Object?> data,
  }) async {
    this.ownerUserId = ownerUserId;
    this.data = data;
  }
}
