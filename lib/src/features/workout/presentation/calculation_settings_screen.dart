import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../auth/application/logout_controller.dart';
import '../application/calculation_settings_controller.dart';
import '../data/calculation_settings.dart';

class CalculationSettingsScreen extends ConsumerStatefulWidget {
  const CalculationSettingsScreen({super.key});

  @override
  ConsumerState<CalculationSettingsScreen> createState() =>
      _CalculationSettingsScreenState();
}

class _CalculationSettingsScreenState
    extends ConsumerState<CalculationSettingsScreen> {
  final _pushUpRatioController = TextEditingController();
  final _rir2Controller = TextEditingController();
  final _rir5Controller = TextEditingController();
  final _unknownRirController = TextEditingController();
  final _chestController = TextEditingController();
  final _tricepsController = TextEditingController();
  final _frontDeltoidController = TextEditingController();
  bool _loadedSettingsApplied = false;

  @override
  void initState() {
    super.initState();
    _applySettings(const CalculationSettings.standard());
  }

  @override
  void dispose() {
    _pushUpRatioController.dispose();
    _rir2Controller.dispose();
    _rir5Controller.dispose();
    _unknownRirController.dispose();
    _chestController.dispose();
    _tricepsController.dispose();
    _frontDeltoidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(calculationSettingsControllerProvider);
    final settingsState = controller.value;
    final CalculationSettings settings;
    if (settingsState == null) {
      settings = ref.watch(calculationSettingsProvider);
    } else {
      settings = settingsState.settings;
    }
    final logout = ref.watch(logoutControllerProvider);
    final isSaving = settingsState?.isSaving ?? false;

    ref.listen(calculationSettingsControllerProvider, (previous, next) {
      final loadedSettings = next.value?.settings;
      if (!_loadedSettingsApplied && loadedSettings != null) {
        _loadedSettingsApplied = true;
        _applySettings(loadedSettings);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('計算設定'),
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
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  settings.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('customPushUpRatioField'),
                  controller: _pushUpRatioController,
                  enabled: !isSaving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '腕立て伏せ 自重係数',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('customRir2Field'),
                  controller: _rir2Controller,
                  enabled: !isSaving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'RIR 2係数',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('customRir5Field'),
                  controller: _rir5Controller,
                  enabled: !isSaving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'RIR 5係数',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('customUnknownRirField'),
                  controller: _unknownRirController,
                  enabled: !isSaving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'RIR不明係数',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '腕立て伏せ 対象筋配分',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('customChestAllocationField'),
                  controller: _chestController,
                  enabled: !isSaving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '胸',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('customTricepsAllocationField'),
                  controller: _tricepsController,
                  enabled: !isSaving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '上腕三頭筋',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('customFrontDeltoidAllocationField'),
                  controller: _frontDeltoidController,
                  enabled: !isSaving,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '三角筋前部',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (settingsState?.errorMessage != null) ...[
                  Text(
                    settingsState!.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (settingsState?.isSaved ?? false) ...[
                  Text(
                    '計算設定を保存しました',
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
                      : const Text('デフォルトに保存'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _applySettings(CalculationSettings settings) {
    final pushUpAllocations =
        settings.muscleAllocations['push_up'] ??
        const {'chest': 1.0, 'triceps': 0.5, 'front_deltoid': 0.5};
    _pushUpRatioController.text =
        settings.bodyWeightLoadRatioFor('push_up')?.toStringAsFixed(2) ??
        '0.72';
    _rir2Controller.text = (settings.rirMultipliers[2] ?? 0.95).toStringAsFixed(
      2,
    );
    _rir5Controller.text = (settings.rirMultipliers[5] ?? 0.50).toStringAsFixed(
      2,
    );
    _unknownRirController.text = settings.unknownRirMultiplier.toStringAsFixed(
      2,
    );
    _chestController.text = (pushUpAllocations['chest'] ?? 1.0).toStringAsFixed(
      2,
    );
    _tricepsController.text = (pushUpAllocations['triceps'] ?? 0.5)
        .toStringAsFixed(2);
    _frontDeltoidController.text = (pushUpAllocations['front_deltoid'] ?? 0.5)
        .toStringAsFixed(2);
  }

  Future<void> _save() async {
    await ref
        .read(calculationSettingsControllerProvider.notifier)
        .saveDefault(
          bodyWeightRatioText: _pushUpRatioController.text,
          rir2MultiplierText: _rir2Controller.text,
          rir5MultiplierText: _rir5Controller.text,
          unknownRirMultiplierText: _unknownRirController.text,
          chestAllocationText: _chestController.text,
          tricepsAllocationText: _tricepsController.text,
          frontDeltoidAllocationText: _frontDeltoidController.text,
        );
  }
}
