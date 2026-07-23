import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../auth/application/logout_controller.dart';
import '../application/workout_set_input_controller.dart';
import '../data/calculation_settings.dart';
import '../domain/bodyweight_load_calculator.dart';
import '../domain/hard_set_judge.dart';
import '../domain/rir_adjusted_volume_calculator.dart';
import '../domain/set_volume_calculator.dart';

class WorkoutSetInputScreen extends ConsumerStatefulWidget {
  const WorkoutSetInputScreen({super.key});

  @override
  ConsumerState<WorkoutSetInputScreen> createState() =>
      _WorkoutSetInputScreenState();
}

class _WorkoutSetInputScreenState extends ConsumerState<WorkoutSetInputScreen> {
  final _repsController = TextEditingController();
  final _bodyWeightController = TextEditingController();
  final _addedWeightController = TextEditingController();
  final _assistanceWeightController = TextEditingController();
  String? _exerciseId;
  int? _rir;

  @override
  void dispose() {
    _repsController.dispose();
    _bodyWeightController.dispose();
    _addedWeightController.dispose();
    _assistanceWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutInput = ref.watch(workoutSetInputControllerProvider);
    final inputState = workoutInput.value;
    final logout = ref.watch(logoutControllerProvider);
    final isSaving = inputState?.saveStatus == WorkoutSetSaveStatus.saving;
    final estimatedLoad = _estimatedLoad();
    final setVolume = _setVolume(estimatedLoad);
    final rirAdjustedVolume = _rirAdjustedVolume(setVolume);
    final hardSet = _hardSetJudgement();

    return Scaffold(
      appBar: AppBar(
        title: const Text('トレーニング'),
        actions: [
          TextButton(
            onPressed: logout.isLoading
                ? null
                : () async {
                    final succeeded = await ref
                        .read(logoutControllerProvider.notifier)
                        .logout();

                    if (succeeded && context.mounted) {
                      context.go(AppRoutePaths.login);
                    }
                  },
            child: const Text('ログアウト'),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'セット入力',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  key: const Key('workoutExerciseDropdown'),
                  initialValue: _exerciseId,
                  decoration: const InputDecoration(
                    labelText: '種目',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'push_up', child: Text('腕立て伏せ')),
                  ],
                  onChanged: isSaving
                      ? null
                      : (value) => setState(() => _exerciseId = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('workoutRepsField'),
                  controller: _repsController,
                  enabled: !isSaving,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: '回数',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('workoutBodyWeightField'),
                  controller: _bodyWeightController,
                  enabled: !isSaving,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: '体重 kg',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('workoutAddedWeightField'),
                  controller: _addedWeightController,
                  enabled: !isSaving,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: '追加重量 kg',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('workoutAssistanceWeightField'),
                  controller: _assistanceWeightController,
                  enabled: !isSaving,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: '補助重量 kg',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (estimatedLoad != null) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '推定負荷（概算）',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text('${estimatedLoad.toStringAsFixed(1)} kg'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (setVolume != null) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'セットボリューム（概算）',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text('${setVolume.toStringAsFixed(1)} kg'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (rirAdjustedVolume != null) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'RIR補正ボリューム（比較用）',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${rirAdjustedVolume.toStringAsFixed(1)} kg',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '独自比較ルールによる概算値です',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  key: const Key('workoutRirDropdown'),
                  initialValue: _rir,
                  decoration: const InputDecoration(
                    labelText: 'RIR',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (var rir = 0; rir <= 10; rir += 1)
                      DropdownMenuItem(value: rir, child: Text('RIR $rir')),
                  ],
                  onChanged: isSaving
                      ? null
                      : (value) => setState(() => _rir = value),
                ),
                if (hardSet != null) ...[
                  const SizedBox(height: 12),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ハードセット判定',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(hardSet ? 'ハードセット' : '通常セット'),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (inputState?.statusMessage != null) ...[
                  Text(
                    inputState!.statusMessage!,
                    style: TextStyle(
                      color:
                          inputState.saveStatus == WorkoutSetSaveStatus.failed
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (inputState?.saveStatus == WorkoutSetSaveStatus.failed) ...[
                  OutlinedButton(
                    onPressed: isSaving
                        ? null
                        : () => ref
                              .read(workoutSetInputControllerProvider.notifier)
                              .retrySave(),
                    child: const Text('再試行'),
                  ),
                  const SizedBox(height: 12),
                ],
                if (isSaving) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        '保存中',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  onPressed: isSaving ? null : _save,
                  child: isSaving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('保存'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final exerciseId = _exerciseId;
    await ref
        .read(workoutSetInputControllerProvider.notifier)
        .saveSet(
          exerciseId: exerciseId,
          bodyWeightText: _bodyWeightController.text,
          bodyWeightLoadRatio: exerciseId == null
              ? null
              : ref
                    .read(calculationSettingsProvider)
                    .bodyWeightLoadRatioFor(exerciseId),
          addedWeightText: _addedWeightController.text,
          assistanceWeightText: _assistanceWeightController.text,
          repsText: _repsController.text,
          rir: _rir,
        );
  }

  double? _estimatedLoad() {
    final exerciseId = _exerciseId;
    if (exerciseId == null) {
      return null;
    }

    final bodyWeight = double.tryParse(_bodyWeightController.text.trim());
    if (bodyWeight == null) {
      return null;
    }

    final ratio = ref
        .read(calculationSettingsProvider)
        .bodyWeightLoadRatioFor(exerciseId);
    if (ratio == null) {
      return null;
    }

    final addedWeight =
        double.tryParse(_addedWeightController.text.trim()) ?? 0;
    final assistanceWeight =
        double.tryParse(_assistanceWeightController.text.trim()) ?? 0;

    try {
      return const BodyweightLoadCalculator().estimatedLoadKg(
        bodyWeightKg: bodyWeight,
        bodyWeightLoadRatio: ratio,
        addedWeightKg: addedWeight,
        assistanceWeightKg: assistanceWeight,
      );
    } on ArgumentError {
      return null;
    }
  }

  double? _setVolume(double? estimatedLoad) {
    if (estimatedLoad == null) {
      return null;
    }

    final reps = int.tryParse(_repsController.text.trim());
    if (reps == null) {
      return null;
    }

    try {
      return const SetVolumeCalculator().setVolumeKg(
        estimatedLoadKg: estimatedLoad,
        reps: reps,
      );
    } on ArgumentError {
      return null;
    }
  }

  double? _rirAdjustedVolume(double? setVolume) {
    if (setVolume == null) {
      return null;
    }

    try {
      return const RirAdjustedVolumeCalculator().effortAdjustedVolume(
        setVolumeKg: setVolume,
        rir: _rir,
        settings: ref.read(calculationSettingsProvider),
      );
    } on ArgumentError {
      return null;
    }
  }

  bool? _hardSetJudgement() {
    try {
      return const HardSetJudge().isHardSet(_rir);
    } on ArgumentError {
      return null;
    }
  }
}
