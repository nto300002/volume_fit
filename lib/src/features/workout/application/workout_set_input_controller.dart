import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/workout_set_input_repository.dart';

final workoutSetInputControllerProvider =
    AsyncNotifierProvider<WorkoutSetInputController, WorkoutSetInputState>(
      WorkoutSetInputController.new,
    );

class WorkoutSetInputState {
  const WorkoutSetInputState({
    this.draft = const WorkoutSetInputDraft(),
    this.isSaved = false,
    this.successMessage,
    this.errorMessage,
  });

  final WorkoutSetInputDraft draft;
  final bool isSaved;
  final String? successMessage;
  final String? errorMessage;
}

class WorkoutSetInputDraft {
  const WorkoutSetInputDraft({this.exerciseId, this.repsText = '', this.rir});

  final String? exerciseId;
  final String repsText;
  final int? rir;
}

class WorkoutSetInputController extends AsyncNotifier<WorkoutSetInputState> {
  @override
  WorkoutSetInputState build() => const WorkoutSetInputState();

  Future<bool> saveSet({
    String? exerciseId,
    required String repsText,
    int? rir,
  }) async {
    final draft = WorkoutSetInputDraft(
      exerciseId: exerciseId,
      repsText: repsText,
      rir: rir,
    );

    final selectedExerciseId = exerciseId;
    if (selectedExerciseId == null || selectedExerciseId.isEmpty) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: '種目を選択してください'),
      );
      return false;
    }

    final reps = int.tryParse(repsText.trim());
    if (reps == null || reps < 1) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: '回数は1回以上で入力してください'),
      );
      return false;
    }

    final selectedRir = rir;
    if (selectedRir == null) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: 'RIRを選択してください'),
      );
      return false;
    }

    if (selectedRir < 0 || selectedRir > 10) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: 'RIRは0から10で選択してください'),
      );
      return false;
    }

    state = const AsyncLoading();

    try {
      await ref
          .read(workoutSetInputRepositoryProvider)
          .saveDraftSet(
            WorkoutSetDraft(
              exerciseId: selectedExerciseId,
              reps: reps,
              rir: selectedRir,
            ),
          );
      state = AsyncData(
        WorkoutSetInputState(
          draft: draft,
          isSaved: true,
          successMessage: '入力を保存しました',
        ),
      );
      return true;
    } on WorkoutSetInputFailure catch (error) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: error.message),
      );
      return false;
    }
  }
}
