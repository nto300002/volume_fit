import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/firebase/firebase_connection.dart';

void main() {
  test('tracks Firebase initialization contract', () {
    final connection = FirebaseConnection.uninitialized();

    expect(connection.isInitialized, isFalse);
    expect(connection.authAvailable, isFalse);
    expect(connection.firestoreAvailable, isFalse);
  });

  test(
    'marks Authentication and Firestore as available after initialization',
    () {
      final connection = FirebaseConnection.initialized();

      expect(connection.isInitialized, isTrue);
      expect(connection.authAvailable, isTrue);
      expect(connection.firestoreAvailable, isTrue);
    },
  );
}
