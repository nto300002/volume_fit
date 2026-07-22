import 'package:flutter_riverpod/flutter_riverpod.dart';

final calculationSettingsProvider = Provider<CalculationSettings>(
  (ref) => const CalculationSettings.standard(),
);

class CalculationSettings {
  const CalculationSettings({
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
  });

  const CalculationSettings.standard()
    : bodyWeightLoadRatios = const {'push_up': 0.72},
      rirMultipliers = const {0: 1, 1: 1, 2: 0.95, 3: 0.85, 4: 0.70, 5: 0.50},
      highRirMultiplier = 0.30,
      unknownRirMultiplier = 0.70;

  final Map<String, double> bodyWeightLoadRatios;
  final Map<int, double> rirMultipliers;
  final double highRirMultiplier;
  final double unknownRirMultiplier;

  double? bodyWeightLoadRatioFor(String exerciseId) {
    return bodyWeightLoadRatios[exerciseId];
  }

  double rirMultiplierFor(int? rir) {
    if (rir == null) {
      return unknownRirMultiplier;
    }

    return rirMultipliers[rir] ?? highRirMultiplier;
  }
}
