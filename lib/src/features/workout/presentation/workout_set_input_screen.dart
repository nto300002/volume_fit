import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../auth/application/logout_controller.dart';
import '../application/workout_set_input_controller.dart';
import '../data/calculation_settings.dart';
import '../domain/bodyweight_load_calculator.dart';

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
    final isSaving = workoutInput.isLoading;
    final estimatedLoad = _estimatedLoad();

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
                const SizedBox(height: 16),
                if (inputState?.errorMessage != null) ...[
                  Text(
                    inputState!.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (inputState?.successMessage != null) ...[
                  Text(
                    inputState!.successMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
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
    await ref
        .read(workoutSetInputControllerProvider.notifier)
        .saveSet(
          exerciseId: _exerciseId,
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
}
