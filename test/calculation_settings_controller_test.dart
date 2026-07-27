import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/workout/application/calculation_settings_controller.dart';
import 'package:volume_fit/src/features/workout/data/calculation_settings.dart';
import 'package:volume_fit/src/features/workout/data/calculation_settings_repository.dart';

void main() {
  test(
    'saves custom settings and updates the active calculation settings',
    () async {
      final repository = FakeCalculationSettingsRepository();
      final container = ProviderContainer(
        overrides: [
          calculationSettingsRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      await container.read(calculationSettingsControllerProvider.future);

      final succeeded = await container
          .read(calculationSettingsControllerProvider.notifier)
          .saveDefault(
            bodyWeightRatioText: '0.80',
            rir2MultiplierText: '0.90',
            rir5MultiplierText: '0.45',
            unknownRirMultiplierText: '0.60',
            chestAllocationText: '0.80',
            tricepsAllocationText: '0.40',
            frontDeltoidAllocationText: '0.30',
          );

      final state = container.read(calculationSettingsControllerProvider).value;
      final active = container.read(calculationSettingsProvider);
      expect(succeeded, isTrue);
      expect(state?.isSaved, isTrue);
      expect(repository.savedSettings?.bodyWeightLoadRatioFor('push_up'), 0.8);
      expect(repository.savedSettings?.rirMultiplierFor(2), 0.9);
      expect(repository.savedSettings?.rirMultiplierFor(5), 0.45);
      expect(repository.savedSettings?.rirMultiplierFor(null), 0.6);
      expect(
        repository.savedSettings?.muscleAllocations['push_up']?['triceps'],
        0.4,
      );
      expect(active.bodyWeightLoadRatioFor('push_up'), 0.8);
      expect(active.rirMultiplierFor(2), 0.9);
    },
  );

  test('rejects invalid bodyweight ratio before saving', () async {
    final repository = FakeCalculationSettingsRepository();
    final container = ProviderContainer(
      overrides: [
        calculationSettingsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(calculationSettingsControllerProvider.future);

    final succeeded = await container
        .read(calculationSettingsControllerProvider.notifier)
        .saveDefault(
          bodyWeightRatioText: '1.20',
          rir2MultiplierText: '0.90',
          rir5MultiplierText: '0.45',
          unknownRirMultiplierText: '0.60',
          chestAllocationText: '0.80',
          tricepsAllocationText: '0.40',
          frontDeltoidAllocationText: '0.30',
        );

    final state = container.read(calculationSettingsControllerProvider).value;
    expect(succeeded, isFalse);
    expect(repository.saveCallCount, 0);
    expect(state?.errorMessage, '自重係数は0より大きく1以下で入力してください');
  });
}

class FakeCalculationSettingsRepository
    implements CalculationSettingsRepository {
  int saveCallCount = 0;
  CalculationSettings? savedSettings;

  @override
  Future<CalculationSettings?> fetchDefault() async => savedSettings;

  @override
  Future<void> saveDefault(CalculationSettings settings) async {
    saveCallCount += 1;
    savedSettings = settings;
  }
}
