import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/app/app_environment.dart';
import 'package:volume_fit/src/firebase/firebase_options.dart';

void main() {
  group('firebaseOptionsFor', () {
    test('returns development Firebase options', () {
      final options = firebaseOptionsFor(
        AppEnvironmentConfig.parse('development'),
      );

      expect(options, isA<FirebaseOptions>());
      expect(options.projectId, 'training-ai-dev');
      expect(options.authDomain, 'training-ai-dev.firebaseapp.com');
    });

    test('returns staging Firebase options', () {
      final options = firebaseOptionsFor(AppEnvironmentConfig.parse('staging'));

      expect(options.projectId, 'training-ai-stg');
      expect(options.authDomain, 'training-ai-stg.firebaseapp.com');
    });

    test('returns production Firebase options', () {
      final options = firebaseOptionsFor(
        AppEnvironmentConfig.parse('production'),
      );

      expect(options.projectId, 'training-ai-prod');
      expect(options.authDomain, 'training-ai-prod.firebaseapp.com');
    });
  });
}
