import '../data/calculation_settings.dart';

class RirAdjustedVolumeCalculator {
  const RirAdjustedVolumeCalculator();

  double effortAdjustedVolume({
    required double setVolumeKg,
    required int? rir,
    required CalculationSettings settings,
  }) {
    if (setVolumeKg < 0) {
      throw ArgumentError.value(setVolumeKg, 'setVolumeKg');
    }

    if (rir != null && rir < 0) {
      throw ArgumentError.value(rir, 'rir');
    }

    return setVolumeKg * settings.rirMultiplierFor(rir);
  }
}
