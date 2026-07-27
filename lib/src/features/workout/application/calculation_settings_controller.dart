import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/calculation_settings.dart';
import '../data/calculation_settings_repository.dart';

final calculationSettingsControllerProvider =
    AsyncNotifierProvider<
      CalculationSettingsController,
      CalculationSettingsControllerState
    >(CalculationSettingsController.new);

class CalculationSettingsControllerState {
  const CalculationSettingsControllerState({
    required this.settings,
    this.isSaving = false,
    this.isSaved = false,
    this.errorMessage,
  });

  final CalculationSettings settings;
  final bool isSaving;
  final bool isSaved;
  final String? errorMessage;
}

class CalculationSettingsController
    extends AsyncNotifier<CalculationSettingsControllerState> {
  @override
  Future<CalculationSettingsControllerState> build() async {
    try {
      final stored = await ref
          .watch(calculationSettingsRepositoryProvider)
          .fetchDefault();
      final CalculationSettings settings;
      if (stored == null) {
        settings = ref.read(calculationSettingsProvider);
      } else {
        settings = stored;
      }
      ref
          .read(activeCalculationSettingsProvider.notifier)
          .setSettings(settings);
      return CalculationSettingsControllerState(settings: settings);
    } on CalculationSettingsFailure {
      final settings = ref.read(calculationSettingsProvider);
      return CalculationSettingsControllerState(settings: settings);
    }
  }

  Future<bool> saveDefault({
    required String bodyWeightRatioText,
    required String rir2MultiplierText,
    required String rir5MultiplierText,
    required String unknownRirMultiplierText,
    required String chestAllocationText,
    required String tricepsAllocationText,
    required String frontDeltoidAllocationText,
  }) async {
    final current = _currentSettings();
    final next = _validatedSettings(
      current: current,
      bodyWeightRatioText: bodyWeightRatioText,
      rir2MultiplierText: rir2MultiplierText,
      rir5MultiplierText: rir5MultiplierText,
      unknownRirMultiplierText: unknownRirMultiplierText,
      chestAllocationText: chestAllocationText,
      tricepsAllocationText: tricepsAllocationText,
      frontDeltoidAllocationText: frontDeltoidAllocationText,
    );
    if (next == null) {
      return false;
    }

    state = AsyncData(
      CalculationSettingsControllerState(settings: current, isSaving: true),
    );
    try {
      await ref.read(calculationSettingsRepositoryProvider).saveDefault(next);
      ref.read(activeCalculationSettingsProvider.notifier).setSettings(next);
      state = AsyncData(
        CalculationSettingsControllerState(settings: next, isSaved: true),
      );
      return true;
    } on CalculationSettingsFailure catch (error) {
      state = AsyncData(
        CalculationSettingsControllerState(
          settings: current,
          errorMessage: error.message,
        ),
      );
      return false;
    }
  }

  CalculationSettings? _validatedSettings({
    required CalculationSettings current,
    required String bodyWeightRatioText,
    required String rir2MultiplierText,
    required String rir5MultiplierText,
    required String unknownRirMultiplierText,
    required String chestAllocationText,
    required String tricepsAllocationText,
    required String frontDeltoidAllocationText,
  }) {
    final bodyWeightRatio = _ratio(
      bodyWeightRatioText,
      '自重係数は0より大きく1以下で入力してください',
    );
    if (bodyWeightRatio == null) {
      return null;
    }

    final rir2 = _multiplier(rir2MultiplierText, 'RIR 2係数は0以上1以下で入力してください');
    if (rir2 == null) {
      return null;
    }

    final rir5 = _multiplier(rir5MultiplierText, 'RIR 5係数は0以上1以下で入力してください');
    if (rir5 == null) {
      return null;
    }

    final unknownRir = _multiplier(
      unknownRirMultiplierText,
      'RIR不明係数は0以上1以下で入力してください',
    );
    if (unknownRir == null) {
      return null;
    }

    final chest = _multiplier(chestAllocationText, '胸の配分は0以上1以下で入力してください');
    if (chest == null) {
      return null;
    }

    final triceps = _multiplier(
      tricepsAllocationText,
      '上腕三頭筋の配分は0以上1以下で入力してください',
    );
    if (triceps == null) {
      return null;
    }

    final frontDeltoid = _multiplier(
      frontDeltoidAllocationText,
      '三角筋前部の配分は0以上1以下で入力してください',
    );
    if (frontDeltoid == null) {
      return null;
    }

    final rirMultipliers = Map<int, double>.from(current.rirMultipliers);
    rirMultipliers[2] = rir2;
    rirMultipliers[5] = rir5;

    return current.copyWith(
      id: CalculationSettings.defaultCustomSettingId,
      name: '自分用設定',
      baseVersion: CalculationSettings.standardVersion,
      bodyWeightLoadRatios: {
        ...current.bodyWeightLoadRatios,
        'push_up': bodyWeightRatio,
      },
      rirMultipliers: rirMultipliers,
      unknownRirMultiplier: unknownRir,
      muscleAllocations: {
        ...current.muscleAllocations,
        'push_up': {
          'chest': chest,
          'triceps': triceps,
          'front_deltoid': frontDeltoid,
        },
      },
    );
  }

  double? _ratio(String text, String message) {
    final value = double.tryParse(text.trim());
    if (value == null || value <= 0 || value > 1) {
      _fail(message);
      return null;
    }

    return value;
  }

  double? _multiplier(String text, String message) {
    final value = double.tryParse(text.trim());
    if (value == null || value < 0 || value > 1) {
      _fail(message);
      return null;
    }

    return value;
  }

  void _fail(String message) {
    final current = _currentSettings();
    state = AsyncData(
      CalculationSettingsControllerState(
        settings: current,
        errorMessage: message,
      ),
    );
  }

  CalculationSettings _currentSettings() {
    final stateSettings = state.value?.settings;
    if (stateSettings != null) {
      return stateSettings;
    }

    return ref.read(calculationSettingsProvider);
  }
}
