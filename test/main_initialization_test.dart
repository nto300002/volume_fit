import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('main initializes Firebase before running the app', () {
    final mainSource = File('lib/main.dart').readAsStringSync();

    expect(mainSource, contains('WidgetsFlutterBinding.ensureInitialized()'));
    expect(mainSource, contains('Firebase.initializeApp'));
    expect(mainSource, contains('firebaseOptionsFor(AppEnvironmentConfig.current())'));
    expect(mainSource, contains('ProviderScope'));
  });
}
