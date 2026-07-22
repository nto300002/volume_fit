class SetVolumeCalculator {
  const SetVolumeCalculator();

  double setVolumeKg({required double estimatedLoadKg, required int reps}) {
    if (estimatedLoadKg < 0) {
      throw ArgumentError.value(estimatedLoadKg, 'estimatedLoadKg');
    }

    if (reps < 0) {
      throw ArgumentError.value(reps, 'reps');
    }

    return estimatedLoadKg * reps;
  }
}
