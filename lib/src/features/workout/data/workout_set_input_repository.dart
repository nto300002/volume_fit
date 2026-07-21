import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutSetInputRepositoryProvider = Provider<WorkoutSetInputRepository>(
  (ref) => const InMemoryWorkoutSetInputRepository(),
);

abstract interface class WorkoutSetInputRepository {
  Future<void> saveDraftSet(WorkoutSetDraft draft);
}

class WorkoutSetDraft {
  const WorkoutSetDraft({
    required this.exerciseId,
    required this.reps,
    required this.rir,
  });

  final String exerciseId;
  final int reps;
  final int rir;
}

class WorkoutSetInputFailure implements Exception {
  const WorkoutSetInputFailure(this.message);

  final String message;
}

class InMemoryWorkoutSetInputRepository implements WorkoutSetInputRepository {
  const InMemoryWorkoutSetInputRepository();

  @override
  Future<void> saveDraftSet(WorkoutSetDraft draft) async {}
}
