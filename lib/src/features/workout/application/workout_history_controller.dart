import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/workout_history_repository.dart';

final workoutHistoryControllerProvider =
    AsyncNotifierProvider<WorkoutHistoryController, WorkoutHistoryState>(
      WorkoutHistoryController.new,
    );

class WorkoutHistoryState {
  const WorkoutHistoryState({
    required this.sessions,
    this.periodFrom,
    this.periodTo,
  });

  final List<WorkoutHistorySession> sessions;
  final DateTime? periodFrom;
  final DateTime? periodTo;
}

class WorkoutHistoryController extends AsyncNotifier<WorkoutHistoryState> {
  @override
  Future<WorkoutHistoryState> build() async {
    final sessions = await ref
        .read(workoutHistoryRepositoryProvider)
        .fetchRecent();
    return WorkoutHistoryState(sessions: sessions);
  }

  Future<void> loadRecent() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final sessions = await ref
          .read(workoutHistoryRepositoryProvider)
          .fetchRecent();
      return WorkoutHistoryState(sessions: sessions);
    });
  }

  Future<void> loadPeriod({
    required DateTime from,
    required DateTime to,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final sessions = await ref
          .read(workoutHistoryRepositoryProvider)
          .fetchByCompletedAt(from: from, to: to);
      return WorkoutHistoryState(
        sessions: sessions,
        periodFrom: from,
        periodTo: to,
      );
    });
  }
}
