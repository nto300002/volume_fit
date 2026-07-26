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

  @override
  Future<List<WorkoutHistoryDocument>> fetch(WorkoutHistoryQuery query) async {
    lastQuery = query;
    return documents;
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
