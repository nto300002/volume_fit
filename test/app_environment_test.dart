import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/app/app_environment.dart';

void main() {
  group('AppEnvironment', () {
    test('defaults to development when no value is provided', () {
      expect(
        AppEnvironmentConfig.parse('').environment,
        AppEnvironment.development,
      );
    });

    test('parses supported environment names', () {
      expect(
        AppEnvironmentConfig.parse('development').environment,
        AppEnvironment.development,
      );
      expect(
        AppEnvironmentConfig.parse('staging').environment,
        AppEnvironment.staging,
      );
      expect(
        AppEnvironmentConfig.parse('production').environment,
        AppEnvironment.production,
      );
    });

    test('keeps Firebase project ids separated by environment', () {
      expect(
        AppEnvironmentConfig.parse('development').firebaseProjectId,
        'training-ai-dev',
      );
      expect(
        AppEnvironmentConfig.parse('staging').firebaseProjectId,
        'training-ai-stg',
      );
      expect(
        AppEnvironmentConfig.parse('production').firebaseProjectId,
        'training-ai-prod',
      );
    });

    test('shows environment labels only outside production', () {
      expect(
        AppEnvironmentConfig.parse('development').showsEnvironmentLabel,
        isTrue,
      );
      expect(
        AppEnvironmentConfig.parse('staging').showsEnvironmentLabel,
        isTrue,
      );
      expect(
        AppEnvironmentConfig.parse('production').showsEnvironmentLabel,
        isFalse,
      );
    });

    test('rejects unsupported environment names', () {
      expect(
        () => AppEnvironmentConfig.parse('local'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
