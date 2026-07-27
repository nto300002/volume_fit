import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../auth/application/logout_controller.dart';
import '../application/workout_plan_controller.dart';

class WorkoutPlanScreen extends ConsumerStatefulWidget {
  const WorkoutPlanScreen({super.key});

  @override
  ConsumerState<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends ConsumerState<WorkoutPlanScreen> {
  final _dateController = TextEditingController();
  final _loadController = TextEditingController();
  final _repsController = TextEditingController();
  final _setCountController = TextEditingController();
  final _memoController = TextEditingController();
  final _sourceAiHistoryController = TextEditingController();
  String? _exerciseId;
  String? _exerciseName;
  int? _targetRir;

  @override
  void dispose() {
    _dateController.dispose();
    _loadController.dispose();
    _repsController.dispose();
    _setCountController.dispose();
    _memoController.dispose();
    _sourceAiHistoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(workoutPlanControllerProvider).value;
    final logout = ref.watch(logoutControllerProvider);
    final isSaving = plan?.isSaving ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('次回予定'),
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
                TextField(
                  key: const Key('workoutPlanDateField'),
                  controller: _dateController,
                  enabled: !isSaving,
                  decoration: const InputDecoration(
                    labelText: '予定日 YYYY-MM-DD',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: const Key('workoutPlanExerciseDropdown'),
                  initialValue: _exerciseId,
                  decoration: const InputDecoration(
                    labelText: '種目',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'bench_press',
                      child: Text('ベンチプレス'),
                    ),
                    DropdownMenuItem(value: 'push_up', child: Text('腕立て伏せ')),
                    DropdownMenuItem(
                      value: 'dumbbell_curl',
                      child: Text('ダンベルカール'),
                    ),
                  ],
                  onChanged: isSaving
                      ? null
                      : (value) => setState(() {
                          _exerciseId = value;
                          _exerciseName = _exerciseNameFor(value);
                        }),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('workoutPlanLoadField'),
                  controller: _loadController,
                  enabled: !isSaving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '重量/負荷 kg',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('workoutPlanRepsField'),
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
                  key: const Key('workoutPlanSetCountField'),
                  controller: _setCountController,
                  enabled: !isSaving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'セット数',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  key: const Key('workoutPlanTargetRirDropdown'),
                  initialValue: _targetRir,
                  decoration: const InputDecoration(
                    labelText: '目標RIR',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (var rir = 0; rir <= 10; rir += 1)
                      DropdownMenuItem(value: rir, child: Text('RIR $rir')),
                  ],
                  onChanged: isSaving
                      ? null
                      : (value) => setState(() => _targetRir = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('workoutPlanMemoField'),
                  controller: _memoController,
                  enabled: !isSaving,
                  decoration: const InputDecoration(
                    labelText: 'メモ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('workoutPlanSourceAiHistoryField'),
                  controller: _sourceAiHistoryController,
                  enabled: !isSaving,
                  decoration: const InputDecoration(
                    labelText: '元AI出力履歴ID',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (plan?.errorMessage != null) ...[
                  Text(
                    plan!.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (plan?.isSaved ?? false) ...[
                  Text(
                    '次回予定を保存しました',
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
        .read(workoutPlanControllerProvider.notifier)
        .savePlan(
          plannedDateText: _dateController.text,
          exerciseId: _exerciseId,
          exerciseName: _exerciseName,
          resistanceType: _resistanceTypeFor(_exerciseId),
          loadText: _loadController.text,
          repsText: _repsController.text,
          setCountText: _setCountController.text,
          targetRir: _targetRir,
          memo: _memoController.text,
          sourceAiExportHistoryId: _sourceAiHistoryController.text,
        );
  }

  String? _exerciseNameFor(String? exerciseId) {
    return switch (exerciseId) {
      'bench_press' => 'ベンチプレス',
      'push_up' => '腕立て伏せ',
      'dumbbell_curl' => 'ダンベルカール',
      _ => null,
    };
  }

  String _resistanceTypeFor(String? exerciseId) {
    return switch (exerciseId) {
      'push_up' => 'body_weight',
      _ => 'external_weight',
    };
  }
}
