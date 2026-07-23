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
  const WorkoutSetInputDraft({
    this.exerciseId,
    this.bodyWeightText = '',
    this.addedWeightText = '',
    this.assistanceWeightText = '',
    this.repsText = '',
    this.rir,
  });

  final String? exerciseId;
  final String bodyWeightText;
  final String addedWeightText;
  final String assistanceWeightText;
  final String repsText;
  final int? rir;
}

class WorkoutSetInputController extends AsyncNotifier<WorkoutSetInputState> {
  @override
  WorkoutSetInputState build() => const WorkoutSetInputState();

  Future<bool> saveSet({
    String? exerciseId,
    String? bodyWeightText,
    double? bodyWeightLoadRatio,
    String? addedWeightText,
    String? assistanceWeightText,
    required String repsText,
    int? rir,
  }) async {
    final draft = WorkoutSetInputDraft(
      exerciseId: exerciseId,
      bodyWeightText: bodyWeightText ?? '',
      addedWeightText: addedWeightText ?? '',
      assistanceWeightText: assistanceWeightText ?? '',
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

    final bodyWeight = double.tryParse((bodyWeightText ?? '').trim());
    if (bodyWeight == null) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: '体重を入力してください'),
      );
      return false;
    }

    if (bodyWeight <= 0 || bodyWeight > 500) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: '体重は0より大きい値で入力してください'),
      );
      return false;
    }

    final selectedBodyWeightLoadRatio = bodyWeightLoadRatio;
    if (selectedBodyWeightLoadRatio == null ||
        selectedBodyWeightLoadRatio < 0 ||
        selectedBodyWeightLoadRatio > 1) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: '自重負荷係数を確認してください'),
      );
      return false;
    }

    final addedWeight = _optionalWeight(addedWeightText);
    if (addedWeight == null) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: '追加重量は0以上で入力してください'),
      );
      return false;
    }

    final assistanceWeight = _optionalWeight(assistanceWeightText);
    if (assistanceWeight == null) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: '補助重量は0以上で入力してください'),
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
              bodyWeightKg: bodyWeight,
              bodyWeightLoadRatio: selectedBodyWeightLoadRatio,
              addedWeightKg: addedWeight,
              assistanceWeightKg: assistanceWeight,
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

  double? _optionalWeight(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return 0;
    }

    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed < 0) {
      return null;
    }

    return parsed;
  }
}
