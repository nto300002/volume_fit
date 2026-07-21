import 'package:flutter_riverpod/flutter_riverpod.dart';

final calculationSettingsProvider = Provider<CalculationSettings>(
  (ref) => const CalculationSettings.standard(),
);

class CalculationSettings {
  const CalculationSettings({required this.bodyWeightLoadRatios});

  const CalculationSettings.standard()
    : bodyWeightLoadRatios = const {'push_up': 0.72};

  final Map<String, double> bodyWeightLoadRatios;

  double? bodyWeightLoadRatioFor(String exerciseId) {
    return bodyWeightLoadRatios[exerciseId];
  }
}
