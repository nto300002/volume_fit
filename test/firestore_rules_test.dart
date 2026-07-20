import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Firestore security rules', () {
    late String rules;

    setUpAll(() {
      rules = File('firestore.rules').readAsStringSync();
    });

    test('deny by default and restrict user documents to the signed-in owner', () {
      expect(rules, contains("rules_version = '2';"));
      expect(rules, contains('match /users/{userId}'));
      expect(rules, contains('function isSignedIn()'));
      expect(rules, contains('function isOwner(userId)'));
      expect(rules, contains('request.auth != null'));
      expect(rules, contains('request.auth.uid == userId'));
      expect(rules, contains('allow read: if isOwner(userId);'));
      expect(rules, contains('allow delete: if isOwner(userId);'));
      expect(rules, contains('match /{document=**}'));
      expect(rules, contains('allow read, write: if false;'));
    });

    test('requires immutable ownership and audit fields on writes', () {
      expect(rules, contains('hasRequiredDocumentFields(userId)'));
      expect(rules, contains('request.resource.data.ownerUserId == userId'));
      expect(rules, contains('request.resource.data.createdAt is timestamp'));
      expect(rules, contains('request.resource.data.updatedAt is timestamp'));
      expect(rules, contains('request.resource.data.schemaVersion is int'));
      expect(rules, contains('immutableFieldsUnchanged()'));
      expect(rules, contains('request.resource.data.ownerUserId == resource.data.ownerUserId'));
      expect(rules, contains('request.resource.data.createdAt == resource.data.createdAt'));
      expect(rules, contains('request.resource.data.schemaVersion == resource.data.schemaVersion'));
    });

    test('guards workout set numeric boundaries', () {
      expect(rules, contains('function isValidWorkoutSet(workoutSet)'));
      expect(rules, contains('workoutSet.reps >= 0'));
      expect(rules, contains('workoutSet.reps <= 999'));
      expect(rules, contains('workoutSet.rir >= 0'));
      expect(rules, contains('workoutSet.rir <= 10'));
      expect(rules, contains('workoutSet.externalWeightKg >= 0'));
      expect(rules, contains('workoutSet.externalWeightKg <= 1000'));
      expect(rules, contains('workoutSet.bodyWeightKg >= 0'));
      expect(rules, contains('workoutSet.bodyWeightKg <= 500'));
      expect(rules, contains('workoutSet.bodyWeightLoadRatio >= 0'));
      expect(rules, contains('workoutSet.bodyWeightLoadRatio <= 1'));
    });

    test('is referenced from Firebase configuration', () {
      final firebaseConfig = File('firebase.json').readAsStringSync();

      expect(firebaseConfig, contains('"firestore"'));
      expect(firebaseConfig, contains('"rules": "firestore.rules"'));
    });
  });
}
