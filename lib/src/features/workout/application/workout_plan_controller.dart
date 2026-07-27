import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/workout_plan_repository.dart';

final workoutPlanControllerProvider =
    AsyncNotifierProvider<WorkoutPlanController, WorkoutPlanState>(
      WorkoutPlanController.new,
    );

class WorkoutPlanState {
  const WorkoutPlanState({
    this.isSaving = false,
    this.isSaved = false,
    this.errorMessage,
  });

  final bool isSaving;
  final bool isSaved;
  final String? errorMessage;
}

class WorkoutPlanController extends AsyncNotifier<WorkoutPlanState> {
  @override
  WorkoutPlanState build() => const WorkoutPlanState();

  Future<bool> savePlan({
    required String plannedDateText,
    required String? exerciseId,
    required String? exerciseName,
    required String resistanceType,
    required String loadText,
    required String repsText,
    required String setCountText,
    required int? targetRir,
    String? memo,
    String? sourceAiExportHistoryId,
  }) async {
    final draft = _validatedDraft(
      plannedDateText: plannedDateText,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      resistanceType: resistanceType,
      loadText: loadText,
      repsText: repsText,
      setCountText: setCountText,
      targetRir: targetRir,
      memo: memo,
      sourceAiExportHistoryId: sourceAiExportHistoryId,
    );
    if (draft == null) {
      return false;
    }

    state = const AsyncData(WorkoutPlanState(isSaving: true));
    try {
      await ref.read(workoutPlanRepositoryProvider).savePlan(draft);
      state = const AsyncData(WorkoutPlanState(isSaved: true));
      return true;
    } on WorkoutPlanFailure catch (error) {
      state = AsyncData(WorkoutPlanState(errorMessage: error.message));
      return false;
    }
  }

  WorkoutPlanDraft? _validatedDraft({
    required String plannedDateText,
    required String? exerciseId,
    required String? exerciseName,
    required String resistanceType,
    required String loadText,
    required String repsText,
    required String setCountText,
    required int? targetRir,
    String? memo,
    String? sourceAiExportHistoryId,
  }) {
    final trimmedDate = plannedDateText.trim();
    if (trimmedDate.isEmpty) {
      _fail('予定日を入力してください');
      return null;
    }

    final plannedDate = DateTime.tryParse(trimmedDate);
    if (plannedDate == null) {
      _fail('予定日はYYYY-MM-DDで入力してください');
      return null;
    }

    final selectedExerciseId = exerciseId;
    final selectedExerciseName = exerciseName;
    if (selectedExerciseId == null ||
        selectedExerciseId.isEmpty ||
        selectedExerciseName == null ||
        selectedExerciseName.isEmpty) {
      _fail('種目を選択してください');
      return null;
    }

    final load = double.tryParse(loadText.trim());
    if (load == null || load <= 0 || load > 1000) {
      _fail('重量は0より大きい値で入力してください');
      return null;
    }

    final reps = int.tryParse(repsText.trim());
    if (reps == null || reps < 1 || reps > 999) {
      _fail('回数は1回以上で入力してください');
      return null;
    }

    final setCount = int.tryParse(setCountText.trim());
    if (setCount == null || setCount < 1 || setCount > 99) {
      _fail('セット数は1以上で入力してください');
      return null;
    }

    final selectedTargetRir = targetRir;
    if (selectedTargetRir == null ||
        selectedTargetRir < 0 ||
        selectedTargetRir > 10) {
      _fail('目標RIRを選択してください');
      return null;
    }

    return WorkoutPlanDraft(
      plannedDate: DateTime.utc(
        plannedDate.year,
        plannedDate.month,
        plannedDate.day,
      ),
      exerciseId: selectedExerciseId,
      exerciseName: selectedExerciseName,
      resistanceType: resistanceType,
      plannedLoadKg: load,
      plannedReps: reps,
      plannedSetCount: setCount,
      targetRir: selectedTargetRir,
      memo: _blankToNull(memo),
      sourceAiExportHistoryId: _blankToNull(sourceAiExportHistoryId),
    );
  }

  void _fail(String message) {
    state = AsyncData(WorkoutPlanState(errorMessage: message));
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }
}
