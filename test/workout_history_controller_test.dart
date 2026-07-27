import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/workout/application/workout_history_controller.dart';
import 'package:volume_fit/src/features/workout/data/workout_history_repository.dart';

void main() {
  test('loads recent workout history on build', () async {
    final repository = FakeWorkoutHistoryRepository(
      sessions: [
        WorkoutHistorySession(
          id: 'session-1',
          completedAt: DateTime.utc(2026, 7, 25, 12),
          exerciseSummary: 'ベンチプレス',
          setCount: 1,
          totalVolumeKg: 600,
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        workoutHistoryRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(workoutHistoryControllerProvider.future);

    expect(repository.fetchRecentCallCount, 1);
    expect(state.sessions.single.exerciseSummary, 'ベンチプレス');
    expect(state.periodFrom, isNull);
    expect(state.periodTo, isNull);
  });

  test('loads workout history for a selected period', () async {
    final repository = FakeWorkoutHistoryRepository(sessions: []);
    final container = ProviderContainer(
      overrides: [
        workoutHistoryRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final from = DateTime.utc(2026, 7, 1);
    final to = DateTime.utc(2026, 7, 31);

    await container
        .read(workoutHistoryControllerProvider.notifier)
        .loadPeriod(from: from, to: to);

    final state = container.read(workoutHistoryControllerProvider).value;
    expect(repository.lastFrom, from);
    expect(repository.lastTo, to);
    expect(state?.periodFrom, from);
    expect(state?.periodTo, to);
  });

  test('loads selected workout session detail', () async {
    final detail = WorkoutSessionDetail(
      id: 'session-1',
      completedAt: DateTime.utc(2026, 7, 25, 12),
      exercises: [
        WorkoutSessionDetailExercise(
          name: 'ベンチプレス',
          sets: [
            WorkoutSessionDetailSet(
              order: 1,
              reps: 10,
              rir: 2,
              estimatedLoadKg: 60,
              setVolumeKg: 600,
              effortAdjustedVolumeKg: 570,
            ),
          ],
        ),
      ],
      totalVolumeKg: 600,
    );
    final repository = FakeWorkoutHistoryRepository(
      sessions: [],
      detail: detail,
    );
    final container = ProviderContainer(
      overrides: [
        workoutHistoryRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final loaded = await container.read(
      workoutSessionDetailControllerProvider('session-1').future,
    );

    expect(repository.lastSessionId, 'session-1');
    expect(loaded.exercises.single.name, 'ベンチプレス');
    expect(loaded.totalVolumeKg, 600);
  });
}

class FakeWorkoutHistoryRepository implements WorkoutHistoryRepository {
  FakeWorkoutHistoryRepository({required this.sessions, this.detail});

  final List<WorkoutHistorySession> sessions;
  final WorkoutSessionDetail? detail;
  int fetchRecentCallCount = 0;
  DateTime? lastFrom;
  DateTime? lastTo;
  String? lastSessionId;

  @override
  Future<List<WorkoutHistorySession>> fetchRecent({int limit = 20}) async {
    fetchRecentCallCount += 1;
    return sessions;
  }

  @override
  Future<List<WorkoutHistorySession>> fetchByCompletedAt({
    required DateTime from,
    required DateTime to,
    int limit = 50,
  }) async {
    lastFrom = from;
    lastTo = to;
    return sessions;
  }

  @override
  Future<WorkoutSessionDetail> fetchSessionDetail(String sessionId) async {
    lastSessionId = sessionId;
    final detail = this.detail;
    if (detail == null) {
      throw const WorkoutHistoryFailure('セッションが見つかりません');
    }

    return detail;
  }
}
