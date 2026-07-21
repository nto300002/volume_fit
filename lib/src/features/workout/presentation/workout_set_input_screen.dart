import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../auth/application/logout_controller.dart';
import '../application/workout_set_input_controller.dart';

class WorkoutSetInputScreen extends ConsumerStatefulWidget {
  const WorkoutSetInputScreen({super.key});

  @override
  ConsumerState<WorkoutSetInputScreen> createState() =>
      _WorkoutSetInputScreenState();
}

class _WorkoutSetInputScreenState extends ConsumerState<WorkoutSetInputScreen> {
  final _repsController = TextEditingController();
  String? _exerciseId;
  int? _rir;

  @override
  void dispose() {
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutInput = ref.watch(workoutSetInputControllerProvider);
    final inputState = workoutInput.value;
    final logout = ref.watch(logoutControllerProvider);
    final isSaving = workoutInput.isLoading;

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
}
