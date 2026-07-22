import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/workout/data/calculation_settings.dart';
import 'package:volume_fit/src/features/workout/domain/rir_adjusted_volume_calculator.dart';

void main() {
  group('RirAdjustedVolumeCalculator', () {
    test('calculates effort adjusted volume from RIR multipliers', () {
      const calculator = RirAdjustedVolumeCalculator();
      const settings = CalculationSettings.standard();

      expect(
        calculator.effortAdjustedVolume(
          setVolumeKg: 100,
          rir: 0,
          settings: settings,
        ),
        100,
      );
      expect(
        calculator.effortAdjustedVolume(
          setVolumeKg: 100,
          rir: 2,
          settings: settings,
        ),
        95,
      );
      expect(
        calculator.effortAdjustedVolume(
          setVolumeKg: 100,
          rir: 4,
          settings: settings,
        ),
        70,
      );
      expect(
        calculator.effortAdjustedVolume(
          setVolumeKg: 100,
          rir: 6,
          settings: settings,
        ),
        30,
      );
    });

    test('uses unknown multiplier when RIR is null', () {
      const calculator = RirAdjustedVolumeCalculator();
      const settings = CalculationSettings.standard();

      final volume = calculator.effortAdjustedVolume(
        setVolumeKg: 100,
        rir: null,
        settings: settings,
      );

      expect(volume, 70);
    });

    test('rejects negative RIR', () {
      const calculator = RirAdjustedVolumeCalculator();
      const settings = CalculationSettings.standard();

      expect(
        () => calculator.effortAdjustedVolume(
          setVolumeKg: 100,
          rir: -1,
          settings: settings,
        ),
        throwsArgumentError,
      );
    });
  });
}
