import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/workout_set_input_repository.dart';

final workoutSetInputControllerProvider =
    AsyncNotifierProvider<WorkoutSetInputController, WorkoutSetInputState>(
      WorkoutSetInputController.new,
    );

enum WorkoutSetSaveStatus {
  idle,
  saving,
  pending,
  offlinePending,
  saved,
  failed,
}

class WorkoutSetInputState {
  const WorkoutSetInputState({
    this.draft = const WorkoutSetInputDraft(),
    this.saveStatus = WorkoutSetSaveStatus.idle,
    this.errorMessage,
  });

  final WorkoutSetInputDraft draft;
  final WorkoutSetSaveStatus saveStatus;
  final String? errorMessage;

  bool get isSaved => saveStatus == WorkoutSetSaveStatus.saved;

  String? get statusMessage {
    return switch (saveStatus) {
      WorkoutSetSaveStatus.saving => '保存中です',
      WorkoutSetSaveStatus.pending => '同期待ちです',
      WorkoutSetSaveStatus.offlinePending => 'オフライン保留中です',
      WorkoutSetSaveStatus.saved => '保存済みです',
      WorkoutSetSaveStatus.failed => errorMessage,
      WorkoutSetSaveStatus.idle => null,
    };
  }
}

class WorkoutSetInputDraft {
  const WorkoutSetInputDraft({
    this.exerciseId,
    this.bodyWeightText = '',
    this.bodyWeightLoadRatio,
    this.addedWeightText = '',
    this.assistanceWeightText = '',
    this.repsText = '',
    this.rir,
  });

  final String? exerciseId;
  final String bodyWeightText;
  final double? bodyWeightLoadRatio;
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
      bodyWeightLoadRatio: bodyWeightLoadRatio,
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

    state = AsyncData(
      WorkoutSetInputState(
        draft: draft,
        saveStatus: WorkoutSetSaveStatus.saving,
      ),
    );

    try {
      final result = await ref
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
        WorkoutSetInputState(draft: draft, saveStatus: _saveStatusFor(result)),
      );
      return true;
    } on WorkoutSetInputFailure catch (error) {
      state = AsyncData(
        WorkoutSetInputState(
          draft: draft,
          saveStatus: WorkoutSetSaveStatus.failed,
          errorMessage: error.message,
        ),
      );
      return false;
    }
  }

  Future<bool> retrySave() async {
    final draft = state.value?.draft;
    if (draft == null) {
      return false;
    }

    return saveSet(
      exerciseId: draft.exerciseId,
      bodyWeightText: draft.bodyWeightText,
      bodyWeightLoadRatio: draft.bodyWeightLoadRatio,
      addedWeightText: draft.addedWeightText,
      assistanceWeightText: draft.assistanceWeightText,
      repsText: draft.repsText,
      rir: draft.rir,
    );
  }

  WorkoutSetSaveStatus _saveStatusFor(WorkoutSetSaveResult result) {
    return switch (result) {
      WorkoutSetSaveResult.saved => WorkoutSetSaveStatus.saved,
      WorkoutSetSaveResult.pending => WorkoutSetSaveStatus.pending,
      WorkoutSetSaveResult.offlinePending =>
        WorkoutSetSaveStatus.offlinePending,
    };
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
