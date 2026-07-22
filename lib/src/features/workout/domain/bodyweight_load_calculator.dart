class BodyweightLoadCalculator {
  const BodyweightLoadCalculator();

  double estimatedLoadKg({
    required double bodyWeightKg,
    required double bodyWeightLoadRatio,
    double addedWeightKg = 0,
    double assistanceWeightKg = 0,
  }) {
    if (bodyWeightKg <= 0) {
      throw ArgumentError.value(bodyWeightKg, 'bodyWeightKg');
    }

    if (bodyWeightLoadRatio < 0 || bodyWeightLoadRatio > 1) {
      throw ArgumentError.value(bodyWeightLoadRatio, 'bodyWeightLoadRatio');
    }

    if (addedWeightKg < 0) {
      throw ArgumentError.value(addedWeightKg, 'addedWeightKg');
    }

    if (assistanceWeightKg < 0) {
      throw ArgumentError.value(assistanceWeightKg, 'assistanceWeightKg');
    }

    return bodyWeightKg * bodyWeightLoadRatio +
        addedWeightKg -
        assistanceWeightKg;
  }
}
