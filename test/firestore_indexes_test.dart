import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('defines the workout history index used by the Firestore reader', () {
    final config = jsonDecode(
      File('firestore.indexes.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final indexes = config['indexes'] as List<dynamic>;
    final firebaseConfig = File('firebase.json').readAsStringSync();

    expect(firebaseConfig, contains('"indexes": "firestore.indexes.json"'));

    final historyIndex = indexes.cast<Map<String, dynamic>>().singleWhere(
      (index) => index['collectionGroup'] == 'workoutSessions',
    );
    final fields = (historyIndex['fields'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    expect(historyIndex['queryScope'], 'COLLECTION');
    expect(
      fields.map((field) => field['fieldPath']).toList(),
      <String>['isDeleted', 'completedAt'],
    );
    expect(
      fields.map((field) => field['order']).toList(),
      <String>['ASCENDING', 'DESCENDING'],
    );
  });
}
