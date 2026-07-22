import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/workout/domain/set_volume_calculator.dart';

void main() {
  group('SetVolumeCalculator', () {
    test('calculates set volume from estimated load and reps', () {
      const calculator = SetVolumeCalculator();

      final volume = calculator.setVolumeKg(estimatedLoadKg: 57.6, reps: 12);

      expect(volume, closeTo(691.2, 0.001));
    });

    test('allows zero reps as zero volume', () {
      const calculator = SetVolumeCalculator();

      final volume = calculator.setVolumeKg(estimatedLoadKg: 57.6, reps: 0);

      expect(volume, 0);
    });

    test('rejects negative reps', () {
      const calculator = SetVolumeCalculator();

      expect(
        () => calculator.setVolumeKg(estimatedLoadKg: 57.6, reps: -1),
        throwsArgumentError,
      );
    });
  });
}
