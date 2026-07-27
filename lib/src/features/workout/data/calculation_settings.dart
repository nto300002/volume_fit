import 'package:flutter_riverpod/flutter_riverpod.dart';

final calculationSettingsProvider = Provider<CalculationSettings>(
  (ref) => ref.watch(activeCalculationSettingsProvider),
);

final activeCalculationSettingsProvider =
    NotifierProvider<ActiveCalculationSettingsController, CalculationSettings>(
      ActiveCalculationSettingsController.new,
    );

class ActiveCalculationSettingsController
    extends Notifier<CalculationSettings> {
  @override
  CalculationSettings build() => const CalculationSettings.standard();

  void setSettings(CalculationSettings settings) {
    state = settings;
  }
}

class CalculationSettings {
  const CalculationSettings({
    this.id = defaultCustomSettingId,
    this.name = '自分用設定',
    this.baseVersion = standardVersion,
    required this.bodyWeightLoadRatios,
    this.rirMultipliers = const {
      0: 1,
      1: 1,
      2: 0.95,
      3: 0.85,
      4: 0.70,
      5: 0.50,
    },
    this.highRirMultiplier = 0.30,
    this.unknownRirMultiplier = 0.70,
    this.muscleAllocations = const {
      'push_up': {'chest': 1.0, 'triceps': 0.5, 'front_deltoid': 0.5},
    },
  });

  const CalculationSettings.standard()
    : id = standardVersion,
      name = '標準設定',
      baseVersion = standardVersion,
      bodyWeightLoadRatios = const {'push_up': 0.72},
      rirMultipliers = const {0: 1, 1: 1, 2: 0.95, 3: 0.85, 4: 0.70, 5: 0.50},
      highRirMultiplier = 0.30,
      unknownRirMultiplier = 0.70,
      muscleAllocations = const {
        'push_up': {'chest': 1.0, 'triceps': 0.5, 'front_deltoid': 0.5},
      };

  static const standardVersion = 'standard-v1';
  static const defaultCustomSettingId = 'custom-default';

  final String id;
  final String name;
  final String baseVersion;
  final Map<String, double> bodyWeightLoadRatios;
  final Map<int, double> rirMultipliers;
  final double highRirMultiplier;
  final double unknownRirMultiplier;
  final Map<String, Map<String, double>> muscleAllocations;

  double? bodyWeightLoadRatioFor(String exerciseId) {
    return bodyWeightLoadRatios[exerciseId];
  }

  double rirMultiplierFor(int? rir) {
    if (rir == null) {
      return unknownRirMultiplier;
    }

    return rirMultipliers[rir] ?? highRirMultiplier;
  }

  CalculationSettings copyWith({
    String? id,
    String? name,
    String? baseVersion,
    Map<String, double>? bodyWeightLoadRatios,
    Map<int, double>? rirMultipliers,
    double? highRirMultiplier,
    double? unknownRirMultiplier,
    Map<String, Map<String, double>>? muscleAllocations,
  }) {
    return CalculationSettings(
      id: id ?? this.id,
      name: name ?? this.name,
      baseVersion: baseVersion ?? this.baseVersion,
      bodyWeightLoadRatios: bodyWeightLoadRatios ?? this.bodyWeightLoadRatios,
      rirMultipliers: rirMultipliers ?? this.rirMultipliers,
      highRirMultiplier: highRirMultiplier ?? this.highRirMultiplier,
      unknownRirMultiplier: unknownRirMultiplier ?? this.unknownRirMultiplier,
      muscleAllocations: muscleAllocations ?? this.muscleAllocations,
    );
  }
}
