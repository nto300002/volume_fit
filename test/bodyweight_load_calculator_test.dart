import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/workout/domain/bodyweight_load_calculator.dart';

void main() {
  group('BodyweightLoadCalculator', () {
    test(
      'calculates estimated load from body weight coefficient and weights',
      () {
        const calculator = BodyweightLoadCalculator();

        final load = calculator.estimatedLoadKg(
          bodyWeightKg: 80,
          bodyWeightLoadRatio: 0.72,
          addedWeightKg: 5,
          assistanceWeightKg: 10,
        );

        expect(load, closeTo(52.6, 0.001));
      },
    );

    test('uses zero for optional added and assistance weights', () {
      const calculator = BodyweightLoadCalculator();

      final load = calculator.estimatedLoadKg(
        bodyWeightKg: 66.8,
        bodyWeightLoadRatio: 0.72,
      );

      expect(load, closeTo(48.096, 0.001));
    });

    test('rejects invalid body weight load ratio', () {
      const calculator = BodyweightLoadCalculator();

      expect(
        () => calculator.estimatedLoadKg(
          bodyWeightKg: 80,
          bodyWeightLoadRatio: 1.2,
        ),
        throwsArgumentError,
      );
    });
  });
}
