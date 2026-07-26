import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/workout_set_input_repository.dart';
import '../domain/external_weight_load_calculator.dart';

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
    this.sets = const [],
    this.saveStatus = WorkoutSetSaveStatus.idle,
    this.errorMessage,
  });

  final WorkoutSetInputDraft draft;
  final List<WorkoutSetDraft> sets;
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

  double get sessionVolumeKg {
    return sets.fold(0, (sum, set) {
      return sum + set.estimatedLoadKg * set.reps;
    });
  }
}

class WorkoutSetInputDraft {
  const WorkoutSetInputDraft({
    this.exerciseId,
    this.bodyWeightText = '',
    this.bodyWeightLoadRatio,
    this.externalWeightText = '',
    this.externalLoadCountText = '',
    this.addedWeightText = '',
    this.assistanceWeightText = '',
    this.repsText = '',
    this.rir,
  });

  final String? exerciseId;
  final String bodyWeightText;
  final double? bodyWeightLoadRatio;
  final String externalWeightText;
  final String externalLoadCountText;
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
    String? externalWeightText,
    String? externalLoadCountText,
    String? addedWeightText,
    String? assistanceWeightText,
    required String repsText,
    int? rir,
  }) async {
    final draft = WorkoutSetInputDraft(
      exerciseId: exerciseId,
      bodyWeightText: bodyWeightText ?? '',
      bodyWeightLoadRatio: bodyWeightLoadRatio,
      externalWeightText: externalWeightText ?? '',
      externalLoadCountText: externalLoadCountText ?? '',
      addedWeightText: addedWeightText ?? '',
      assistanceWeightText: assistanceWeightText ?? '',
      repsText: repsText,
      rir: rir,
    );

    final validatedDraft = _validatedSetDraft(
      order: 1,
      draft: draft,
      bodyWeightLoadRatio: bodyWeightLoadRatio,
    );
    if (validatedDraft == null) {
      return false;
    }

    state = AsyncData(
      WorkoutSetInputState(
        draft: draft,
        sets: state.value?.sets ?? const [],
        saveStatus: WorkoutSetSaveStatus.saving,
      ),
    );

    try {
      final result = await ref
          .read(workoutSetInputRepositoryProvider)
          .saveDraftSet(validatedDraft);
      state = AsyncData(
        WorkoutSetInputState(
          draft: draft,
          sets: state.value?.sets ?? const [],
          saveStatus: _saveStatusFor(result),
        ),
      );
      return true;
    } on WorkoutSetInputFailure catch (error) {
      state = AsyncData(
        WorkoutSetInputState(
          draft: draft,
          sets: state.value?.sets ?? const [],
          saveStatus: WorkoutSetSaveStatus.failed,
          errorMessage: error.message,
        ),
      );
      return false;
    }
  }

  bool addSet({
    String? exerciseId,
    String? bodyWeightText,
    double? bodyWeightLoadRatio,
    String? externalWeightText,
    String? externalLoadCountText,
    String? addedWeightText,
    String? assistanceWeightText,
    required String repsText,
    int? rir,
  }) {
    final currentState = state.value ?? const WorkoutSetInputState();
    final draft = WorkoutSetInputDraft(
      exerciseId: exerciseId,
      bodyWeightText: bodyWeightText ?? '',
      bodyWeightLoadRatio: bodyWeightLoadRatio,
      externalWeightText: externalWeightText ?? '',
      externalLoadCountText: externalLoadCountText ?? '',
      addedWeightText: addedWeightText ?? '',
      assistanceWeightText: assistanceWeightText ?? '',
      repsText: repsText,
      rir: rir,
    );
    final set = _validatedSetDraft(
      order: currentState.sets.length + 1,
      draft: draft,
      bodyWeightLoadRatio: bodyWeightLoadRatio,
    );
    if (set == null) {
      return false;
    }

    state = AsyncData(
      WorkoutSetInputState(draft: draft, sets: [...currentState.sets, set]),
    );
    return true;
  }

  bool updateSet({
    required int order,
    String? exerciseId,
    String? bodyWeightText,
    double? bodyWeightLoadRatio,
    String? externalWeightText,
    String? externalLoadCountText,
    String? addedWeightText,
    String? assistanceWeightText,
    required String repsText,
    int? rir,
  }) {
    final currentState = state.value ?? const WorkoutSetInputState();
    final draft = WorkoutSetInputDraft(
      exerciseId: exerciseId,
      bodyWeightText: bodyWeightText ?? '',
      bodyWeightLoadRatio: bodyWeightLoadRatio,
      externalWeightText: externalWeightText ?? '',
      externalLoadCountText: externalLoadCountText ?? '',
      addedWeightText: addedWeightText ?? '',
      assistanceWeightText: assistanceWeightText ?? '',
      repsText: repsText,
      rir: rir,
    );
    final set = _validatedSetDraft(
      order: order,
      draft: draft,
      bodyWeightLoadRatio: bodyWeightLoadRatio,
    );
    if (set == null) {
      return false;
    }

    state = AsyncData(
      WorkoutSetInputState(
        draft: draft,
        sets: [
          for (final existing in currentState.sets)
            if (existing.order == order) set else existing,
        ],
      ),
    );
    return true;
  }

  bool duplicateLatestSet() {
    final currentState = state.value ?? const WorkoutSetInputState();
    if (currentState.sets.isEmpty) {
      state = AsyncData(
        WorkoutSetInputState(
          draft: currentState.draft,
          sets: currentState.sets,
          errorMessage: '複製できるセットがありません',
        ),
      );
      return false;
    }

    final latest = currentState.sets.last;
    final duplicated = WorkoutSetDraft(
      order: currentState.sets.length + 1,
      exerciseId: latest.exerciseId,
      externalWeightKg: latest.externalWeightKg,
      bodyWeightKg: latest.bodyWeightKg,
      bodyWeightLoadRatio: latest.bodyWeightLoadRatio,
      addedWeightKg: latest.addedWeightKg,
      assistanceWeightKg: latest.assistanceWeightKg,
      reps: latest.reps,
      rir: latest.rir,
    );

    state = AsyncData(
      WorkoutSetInputState(
        draft: WorkoutSetInputDraft(
          exerciseId: duplicated.exerciseId,
          bodyWeightText: _textForNullableWeight(duplicated.bodyWeightKg),
          bodyWeightLoadRatio: duplicated.bodyWeightLoadRatio,
          externalWeightText: _textForNullableWeight(
            duplicated.externalWeightKg,
          ),
          addedWeightText: _optionalTextForWeight(duplicated.addedWeightKg),
          assistanceWeightText: _optionalTextForWeight(
            duplicated.assistanceWeightKg,
          ),
          repsText: duplicated.reps.toString(),
          rir: duplicated.rir,
        ),
        sets: [...currentState.sets, duplicated],
      ),
    );
    return true;
  }

  Future<bool> saveSession() async {
    final currentState = state.value ?? const WorkoutSetInputState();
    if (currentState.sets.isEmpty) {
      return saveSet(
        exerciseId: currentState.draft.exerciseId,
        bodyWeightText: currentState.draft.bodyWeightText,
        bodyWeightLoadRatio: currentState.draft.bodyWeightLoadRatio,
        externalWeightText: currentState.draft.externalWeightText,
        externalLoadCountText: currentState.draft.externalLoadCountText,
        addedWeightText: currentState.draft.addedWeightText,
        assistanceWeightText: currentState.draft.assistanceWeightText,
        repsText: currentState.draft.repsText,
        rir: currentState.draft.rir,
      );
    }

    state = AsyncData(
      WorkoutSetInputState(
        draft: currentState.draft,
        sets: currentState.sets,
        saveStatus: WorkoutSetSaveStatus.saving,
      ),
    );

    try {
      final result = await ref
          .read(workoutSetInputRepositoryProvider)
          .saveSession(
            WorkoutSessionDraft(
              exerciseId: currentState.sets.first.exerciseId,
              sets: currentState.sets,
            ),
          );
      state = AsyncData(
        WorkoutSetInputState(
          draft: currentState.draft,
          sets: currentState.sets,
          saveStatus: _saveStatusFor(result),
        ),
      );
      return true;
    } on WorkoutSetInputFailure catch (error) {
      state = AsyncData(
        WorkoutSetInputState(
          draft: currentState.draft,
          sets: currentState.sets,
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
      externalWeightText: draft.externalWeightText,
      externalLoadCountText: draft.externalLoadCountText,
      addedWeightText: draft.addedWeightText,
      assistanceWeightText: draft.assistanceWeightText,
      repsText: draft.repsText,
      rir: draft.rir,
    );
  }

  WorkoutSetDraft? _validatedSetDraft({
    required int order,
    required WorkoutSetInputDraft draft,
    required double? bodyWeightLoadRatio,
  }) {
    final selectedExerciseId = draft.exerciseId;
    if (selectedExerciseId == null || selectedExerciseId.isEmpty) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: '種目を選択してください'),
      );
      return null;
    }

    final reps = int.tryParse(draft.repsText.trim());
    if (reps == null || reps < 1) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: '回数は1回以上で入力してください'),
      );
      return null;
    }

    final selectedBodyWeightLoadRatio = bodyWeightLoadRatio;
    final isBodyWeightExercise = !_isExternalWeightExercise(selectedExerciseId);
    final bodyWeight = isBodyWeightExercise
        ? _validatedBodyWeight(draft)
        : null;
    if (isBodyWeightExercise && bodyWeight == null) {
      return null;
    }

    if (isBodyWeightExercise &&
        (selectedBodyWeightLoadRatio == null ||
            selectedBodyWeightLoadRatio < 0 ||
            selectedBodyWeightLoadRatio > 1)) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: '自重負荷係数を確認してください'),
      );
      return null;
    }

    final externalWeight = isBodyWeightExercise
        ? null
        : _validatedExternalWeight(draft);
    if (!isBodyWeightExercise && externalWeight == null) {
      return null;
    }

    final addedWeight = _optionalWeight(draft.addedWeightText);
    if (addedWeight == null) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: '追加重量は0以上で入力してください'),
      );
      return null;
    }

    final assistanceWeight = _optionalWeight(draft.assistanceWeightText);
    if (assistanceWeight == null) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: '補助重量は0以上で入力してください'),
      );
      return null;
    }

    final selectedRir = draft.rir;
    if (selectedRir == null) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: 'RIRを選択してください'),
      );
      return null;
    }

    if (selectedRir < 0 || selectedRir > 10) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: 'RIRは0から10で選択してください'),
      );
      return null;
    }

    return WorkoutSetDraft(
      order: order,
      exerciseId: selectedExerciseId,
      externalWeightKg: externalWeight,
      bodyWeightKg: bodyWeight,
      bodyWeightLoadRatio: isBodyWeightExercise
          ? selectedBodyWeightLoadRatio
          : null,
      addedWeightKg: addedWeight,
      assistanceWeightKg: assistanceWeight,
      reps: reps,
      rir: selectedRir,
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

  double? _validatedBodyWeight(WorkoutSetInputDraft draft) {
    final bodyWeight = double.tryParse(draft.bodyWeightText.trim());
    if (bodyWeight == null) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: '体重を入力してください'),
      );
      return null;
    }

    if (bodyWeight <= 0 || bodyWeight > 500) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: '体重は0より大きい値で入力してください'),
      );
      return null;
    }

    return bodyWeight;
  }

  double? _validatedExternalWeight(WorkoutSetInputDraft draft) {
    final externalWeight = double.tryParse(draft.externalWeightText.trim());
    if (externalWeight == null) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: '重量を入力してください'),
      );
      return null;
    }

    final loadCountText = draft.externalLoadCountText.trim();
    final loadCount = loadCountText.isEmpty ? 1 : int.tryParse(loadCountText);
    if (loadCount == null) {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: '重量の個数を確認してください'),
      );
      return null;
    }

    try {
      return const ExternalWeightLoadCalculator().estimatedLoadKg(
        externalWeightKg: externalWeight,
        numberOfLoads: loadCount,
      );
    } on ArgumentError {
      state = AsyncData(
        WorkoutSetInputState(draft: draft, errorMessage: '重量は0より大きい値で入力してください'),
      );
      return null;
    }
  }

  bool _isExternalWeightExercise(String exerciseId) {
    return switch (exerciseId) {
      'push_up' => false,
      _ => true,
    };
  }

  String _textForWeight(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  String _optionalTextForWeight(double value) {
    if (value == 0) {
      return '';
    }

    return _textForWeight(value);
  }

  String _textForNullableWeight(double? value) {
    if (value == null) {
      return '';
    }

    return _textForWeight(value);
  }
}
