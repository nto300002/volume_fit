import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('enables email and password authentication in Firebase config', () {
    final config = jsonDecode(File('firebase.json').readAsStringSync())
        as Map<String, dynamic>;
    final auth = config['auth'] as Map<String, dynamic>?;
    final providers = auth?['providers'] as Map<String, dynamic>?;

    expect(providers?['emailPassword'], isTrue);
  });
}
