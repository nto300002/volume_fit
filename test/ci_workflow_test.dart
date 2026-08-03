import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('runs analysis and tests for pull requests', () {
    final workflow = File('.github/workflows/flutter-ci.yml').readAsStringSync();

    expect(workflow, contains('pull_request:'));
    expect(workflow, contains('subosito/flutter-action'));
    expect(workflow, contains('flutter analyze'));
    expect(workflow, contains('flutter test'));
  });
}
