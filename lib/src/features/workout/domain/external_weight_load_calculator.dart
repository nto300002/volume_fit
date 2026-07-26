class ExternalWeightLoadCalculator {
  const ExternalWeightLoadCalculator();

  double estimatedLoadKg({
    required double externalWeightKg,
    int numberOfLoads = 1,
  }) {
    if (externalWeightKg <= 0 || externalWeightKg > 1000) {
      throw ArgumentError.value(externalWeightKg, 'externalWeightKg');
    }

    if (numberOfLoads < 1 || numberOfLoads > 20) {
      throw ArgumentError.value(numberOfLoads, 'numberOfLoads');
    }

    final total = externalWeightKg * numberOfLoads;
    if (total > 1000) {
      throw ArgumentError.value(total, 'totalExternalLoadKg');
    }

    return total;
  }
}
