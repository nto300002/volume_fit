import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/workout/domain/external_weight_load_calculator.dart';

void main() {
  test('returns external weight as estimated load', () {
    expect(
      const ExternalWeightLoadCalculator().estimatedLoadKg(
        externalWeightKg: 60,
      ),
      60,
    );
  });

  test('calculates total dumbbell load from per-side load and count', () {
    expect(
      const ExternalWeightLoadCalculator().estimatedLoadKg(
        externalWeightKg: 22.5,
        numberOfLoads: 2,
      ),
      45,
    );
  });

  test('rejects zero or negative external weight', () {
    expect(
      () => const ExternalWeightLoadCalculator().estimatedLoadKg(
        externalWeightKg: 0,
      ),
      throwsArgumentError,
    );
  });
}
