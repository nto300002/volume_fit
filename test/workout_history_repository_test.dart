import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/workout/data/workout_history_repository.dart';
import 'package:volume_fit/src/features/workout/data/workout_set_input_repository.dart';

void main() {
  test('loads recent workout sessions excluding deleted sessions', () async {
    final reader = FakeWorkoutHistoryReader(
      documents: [
        _sessionDocument(
          id: 'newer',
          completedAt: DateTime.utc(2026, 7, 25, 12),
          exerciseName: 'ベンチプレス',
          reps: 10,
          loadKg: 60,
        ),
        _sessionDocument(
          id: 'deleted',
          completedAt: DateTime.utc(2026, 7, 24, 12),
          exerciseName: '腕立て伏せ',
          reps: 12,
          loadKg: 57.6,
          isDeleted: true,
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        currentAuthUserIdProvider.overrideWithValue('uid-1'),
        workoutHistoryReaderProvider.overrideWithValue(reader),
      ],
    );
    addTearDown(container.dispose);

    final sessions = await container
        .read(workoutHistoryRepositoryProvider)
        .fetchRecent(limit: 20);

    expect(reader.lastQuery?.ownerUserId, 'uid-1');
    expect(reader.lastQuery?.limit, 20);
    expect(reader.lastQuery?.includeDeleted, isFalse);
    expect(sessions.map((session) => session.id), ['newer']);
    expect(sessions.single.exerciseSummary, 'ベンチプレス');
    expect(sessions.single.totalVolumeKg, 600);
  });

  test('loads workout sessions by completed date range', () async {
    final from = DateTime.utc(2026, 7, 1);
    final to = DateTime.utc(2026, 7, 31, 23, 59);
    final reader = FakeWorkoutHistoryReader(documents: []);
    final container = ProviderContainer(
      overrides: [
        currentAuthUserIdProvider.overrideWithValue('uid-1'),
        workoutHistoryReaderProvider.overrideWithValue(reader),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(workoutHistoryRepositoryProvider)
        .fetchByCompletedAt(from: from, to: to, limit: 50);

    expect(reader.lastQuery?.from, from);
    expect(reader.lastQuery?.to, to);
    expect(reader.lastQuery?.limit, 50);
  });

  test(
    'loads a workout session detail by id and recalculates set values',
    () async {
      final reader = FakeWorkoutHistoryReader(
        documents: [
          WorkoutHistoryDocument(
            id: 'session-1',
            data: {
              'completedAt': Timestamp.fromDate(DateTime.utc(2026, 7, 25, 12)),
              'isDeleted': false,
              'exercises': [
                {
                  'displayName': '腕立て伏せ',
                  'sets': [
                    {
                      'order': 1,
                      'reps': 12,
                      'rir': 2,
                      'bodyWeightKg': 80,
                      'bodyWeightLoadRatio': 0.72,
                      'addedWeightKg': 0,
                      'assistanceWeightKg': 0,
                    },
                  ],
                },
              ],
            },
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          currentAuthUserIdProvider.overrideWithValue('uid-1'),
          workoutHistoryReaderProvider.overrideWithValue(reader),
        ],
      );
      addTearDown(container.dispose);

      final detail = await container
          .read(workoutHistoryRepositoryProvider)
          .fetchSessionDetail('session-1');

      expect(reader.lastSessionId, 'session-1');
      expect(detail.id, 'session-1');
      expect(detail.exercises.single.name, '腕立て伏せ');
      expect(
        detail.exercises.single.sets.single.estimatedLoadKg,
        closeTo(57.6, 0.001),
      );
      expect(
        detail.exercises.single.sets.single.setVolumeKg,
        closeTo(691.2, 0.001),
      );
      expect(
        detail.exercises.single.sets.single.effortAdjustedVolumeKg,
        closeTo(656.64, 0.001),
      );
      expect(detail.totalVolumeKg, closeTo(691.2, 0.001));
    },
  );

  test('compares a workout session detail with the previous record', () async {
    final currentDate = DateTime.utc(2026, 7, 25, 12);
    final previousDate = DateTime.utc(2026, 7, 18, 12);
    final reader = FakeWorkoutHistoryReader(
      documents: [
        _comparisonDocument(
          id: 'current',
          completedAt: currentDate,
          exerciseName: 'ベンチプレス',
          loadKg: 60,
          reps: 10,
          rir: 2,
          targetMuscleIds: ['chest', 'triceps'],
        ),
        _comparisonDocument(
          id: 'previous',
          completedAt: previousDate,
          exerciseName: 'ベンチプレス',
          loadKg: 50,
          reps: 10,
          rir: 5,
          targetMuscleIds: ['chest', 'front_deltoid'],
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        currentAuthUserIdProvider.overrideWithValue('uid-1'),
        workoutHistoryReaderProvider.overrideWithValue(reader),
      ],
    );
    addTearDown(container.dispose);

    final detail = await container
        .read(workoutHistoryRepositoryProvider)
        .fetchSessionDetail('current');

    final comparison = detail.previousComparison;
    expect(comparison, isNotNull);
    expect(comparison?.label, '前回比');
    expect(comparison?.estimatedVolumeDeltaKg, 100);
    expect(comparison?.effortAdjustedVolumeDeltaKg, 320);
    expect(comparison?.hardSetDelta, 1);
    expect(comparison?.targetMuscleMatchRatio, closeTo(1 / 3, 0.001));
  });

  test('rejects missing session detail', () async {
    final reader = FakeWorkoutHistoryReader(documents: []);
    final container = ProviderContainer(
      overrides: [
        currentAuthUserIdProvider.overrideWithValue('uid-1'),
        workoutHistoryReaderProvider.overrideWithValue(reader),
      ],
    );
    addTearDown(container.dispose);

    expect(
      () => container
          .read(workoutHistoryRepositoryProvider)
          .fetchSessionDetail('missing'),
      throwsA(isA<WorkoutHistoryFailure>()),
    );
  });

  test('rejects history load when auth user is missing', () async {
    final container = ProviderContainer(
      overrides: [
        currentAuthUserIdProvider.overrideWithValue(null),
        workoutHistoryReaderProvider.overrideWithValue(
          FakeWorkoutHistoryReader(documents: []),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      () => container.read(workoutHistoryRepositoryProvider).fetchRecent(),
      throwsA(isA<WorkoutHistoryFailure>()),
    );
  });
}

class FakeWorkoutHistoryReader implements WorkoutHistoryReader {
  FakeWorkoutHistoryReader({required this.documents});

  final List<WorkoutHistoryDocument> documents;
  WorkoutHistoryQuery? lastQuery;
  String? lastSessionId;

  @override
  Future<List<WorkoutHistoryDocument>> fetch(WorkoutHistoryQuery query) async {
    lastQuery = query;
    return documents;
  }

  @override
  Future<WorkoutHistoryDocument?> fetchById({
    required String ownerUserId,
    required String sessionId,
  }) async {
    lastSessionId = sessionId;
    return documents
        .where((document) => document.id == sessionId)
        .cast<WorkoutHistoryDocument?>()
        .firstOrNull;
  }
}

WorkoutHistoryDocument _sessionDocument({
  required String id,
  required DateTime completedAt,
  required String exerciseName,
  required int reps,
  required double loadKg,
  bool isDeleted = false,
}) {
  return WorkoutHistoryDocument(
    id: id,
    data: {
      'completedAt': Timestamp.fromDate(completedAt),
      'isDeleted': isDeleted,
      'exercises': [
        {
          'displayName': exerciseName,
          'sets': [
            {'reps': reps, 'externalWeightKg': loadKg},
          ],
        },
      ],
    },
  );
}

WorkoutHistoryDocument _comparisonDocument({
  required String id,
  required DateTime completedAt,
  required String exerciseName,
  required double loadKg,
  required int reps,
  required int rir,
  required List<String> targetMuscleIds,
}) {
  return WorkoutHistoryDocument(
    id: id,
    data: {
      'completedAt': Timestamp.fromDate(completedAt),
      'isDeleted': false,
      'exercises': [
        {
          'displayName': exerciseName,
          'targetMuscles': [
            for (final muscleId in targetMuscleIds)
              {'muscleId': muscleId, 'allocation': 1.0},
          ],
          'sets': [
            {'order': 1, 'reps': reps, 'rir': rir, 'externalWeightKg': loadKg},
          ],
        },
      ],
    },
  );
}
