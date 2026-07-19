import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:volume_fit/src/app/app_environment.dart';
import 'package:volume_fit/src/app/app_providers.dart';

void main() {
  test('appEnvironmentProvider can be overridden for tests', () {
    final container = ProviderContainer(
      overrides: [
        appEnvironmentProvider.overrideWithValue(
          AppEnvironmentConfig.parse('staging'),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(appEnvironmentProvider).environment,
      AppEnvironment.staging,
    );
  });

  test('clockProvider can be overridden for deterministic time', () {
    final fixedNow = DateTime.utc(2026, 7, 19, 12);
    final container = ProviderContainer(
      overrides: [clockProvider.overrideWithValue(() => fixedNow)],
    );
    addTearDown(container.dispose);

    expect(container.read(clockProvider)(), fixedNow);
  });
}
