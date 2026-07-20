import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/app/app_environment.dart';
import 'package:volume_fit/src/app/app_providers.dart';
import 'package:volume_fit/src/firebase/firebase_providers.dart';

void main() {
  test('firebaseOptionsProvider follows appEnvironmentProvider', () {
    final container = ProviderContainer(
      overrides: [
        appEnvironmentProvider.overrideWithValue(
          AppEnvironmentConfig.parse('production'),
        ),
      ],
    );
    addTearDown(container.dispose);

    final options = container.read(firebaseOptionsProvider);

    expect(options.projectId, 'training-ai-prod');
    expect(options.authDomain, 'training-ai-prod.firebaseapp.com');
  });
}
