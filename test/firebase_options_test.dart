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
      expect(options.projectId, 'volume-fit-dev');
      expect(options.appId, '1:325793484975:web:a09c2e6539f03925a5445a');
      expect(options.messagingSenderId, '325793484975');
      expect(options.apiKey, 'AIzaSyA6U0EwHyQPTXaKk4qegfc01r2Dp7m-mZ8');
      expect(options.authDomain, 'volume-fit-dev.firebaseapp.com');
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
