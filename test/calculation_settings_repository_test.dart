import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/app/app_providers.dart';
import 'package:volume_fit/src/features/workout/data/calculation_settings.dart';
import 'package:volume_fit/src/features/workout/data/calculation_settings_repository.dart';

void main() {
  test('saves custom calculation settings as the default copy', () async {
    final writer = FakeCalculationSettingsWriter();
    final now = DateTime.utc(2026, 7, 27, 9, 30);
    final container = ProviderContainer(
      overrides: [
        currentCalculationSettingsAuthUserIdProvider.overrideWithValue('uid-1'),
        calculationSettingsReaderProvider.overrideWithValue(
          FakeCalculationSettingsReader(),
        ),
        calculationSettingsWriterProvider.overrideWithValue(writer),
        clockProvider.overrideWithValue(() => now),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(calculationSettingsRepositoryProvider)
        .saveDefault(
          const CalculationSettings(
            id: 'custom-default',
            name: '自分用設定',
            bodyWeightLoadRatios: {'push_up': 0.8},
            rirMultipliers: {0: 1, 1: 1, 2: 0.9, 3: 0.8, 4: 0.65, 5: 0.45},
            highRirMultiplier: 0.25,
            unknownRirMultiplier: 0.6,
            muscleAllocations: {
              'push_up': {'chest': 0.8, 'triceps': 0.4, 'front_deltoid': 0.3},
            },
          ),
        );

    expect(writer.ownerUserId, 'uid-1');
    expect(writer.settingId, 'custom-default');
    final data = writer.data;
    expect(data?['schemaVersion'], 1);
    expect(data?['ownerUserId'], 'uid-1');
    expect(data?['name'], '自分用設定');
    expect(data?['baseVersion'], 'standard-v1');
    expect(data?['isDefault'], isTrue);
    expect(data?['createdAt'], now);
    expect(data?['updatedAt'], now);
    expect(data?['revision'], 1);

    final bodyweight = data?['bodyweightCoefficients'] as Map<String, Object?>;
    expect(bodyweight['push_up.standard'], 0.8);
    final rir = data?['rirMultipliers'] as Map<String, Object?>;
    expect(rir['2'], 0.9);
    expect(rir['5'], 0.45);
    expect(rir['unknown'], 0.6);
    final allocations = data?['muscleAllocations'] as Map<String, Object?>;
    final pushUp = allocations['push_up'] as Map<String, Object?>;
    expect(pushUp['chest'], 0.8);
  });

  test('loads the default custom calculation settings', () async {
    final reader = FakeCalculationSettingsReader(
      data: {
        'name': '自分用設定',
        'baseVersion': 'standard-v1',
        'bodyweightCoefficients': {'push_up.standard': 0.8},
        'rirMultipliers': {'0': 1, '1': 1, '2': 0.9, 'unknown': 0.6},
        'muscleAllocations': {
          'push_up': {'chest': 0.8},
        },
      },
    );
    final container = ProviderContainer(
      overrides: [
        currentCalculationSettingsAuthUserIdProvider.overrideWithValue('uid-1'),
        calculationSettingsReaderProvider.overrideWithValue(reader),
        calculationSettingsWriterProvider.overrideWithValue(
          FakeCalculationSettingsWriter(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final settings = await container
        .read(calculationSettingsRepositoryProvider)
        .fetchDefault();

    expect(reader.ownerUserId, 'uid-1');
    expect(settings?.id, 'custom-default');
    expect(settings?.bodyWeightLoadRatioFor('push_up'), 0.8);
    expect(settings?.rirMultiplierFor(2), 0.9);
    expect(settings?.rirMultiplierFor(null), 0.6);
    expect(settings?.muscleAllocations['push_up']?['chest'], 0.8);
  });

  test('rejects save when auth user is missing', () async {
    final container = ProviderContainer(
      overrides: [
        currentCalculationSettingsAuthUserIdProvider.overrideWithValue(null),
        calculationSettingsReaderProvider.overrideWithValue(
          FakeCalculationSettingsReader(),
        ),
        calculationSettingsWriterProvider.overrideWithValue(
          FakeCalculationSettingsWriter(),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      () => container
          .read(calculationSettingsRepositoryProvider)
          .saveDefault(const CalculationSettings.standard()),
      throwsA(isA<CalculationSettingsFailure>()),
    );
  });
}

class FakeCalculationSettingsWriter implements CalculationSettingsWriter {
  String? ownerUserId;
  String? settingId;
  Map<String, Object?>? data;

  @override
  Future<void> setSetting({
    required String ownerUserId,
    required String settingId,
    required Map<String, Object?> data,
  }) async {
    this.ownerUserId = ownerUserId;
    this.settingId = settingId;
    this.data = data;
  }
}

class FakeCalculationSettingsReader implements CalculationSettingsReader {
  FakeCalculationSettingsReader({this.data});

  final Map<String, Object?>? data;
  String? ownerUserId;
  String? settingId;

  @override
  Future<Map<String, Object?>?> fetchSetting({
    required String ownerUserId,
    required String settingId,
  }) async {
    this.ownerUserId = ownerUserId;
    this.settingId = settingId;
    return data;
  }
}
