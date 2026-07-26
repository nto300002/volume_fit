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
}

class FakeWorkoutHistoryRepository implements WorkoutHistoryRepository {
  FakeWorkoutHistoryRepository({required this.sessions});

  final List<WorkoutHistorySession> sessions;
  int fetchRecentCallCount = 0;
  DateTime? lastFrom;
  DateTime? lastTo;

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
}
