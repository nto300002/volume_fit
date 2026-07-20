import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseConnection {
  const FirebaseConnection({
    required this.isInitialized,
    required this.authAvailable,
    required this.firestoreAvailable,
  });

  const FirebaseConnection.uninitialized()
    : isInitialized = false,
      authAvailable = false,
      firestoreAvailable = false;

  const FirebaseConnection.initialized()
    : isInitialized = true,
      authAvailable = true,
      firestoreAvailable = true;

  final bool isInitialized;
  final bool authAvailable;
  final bool firestoreAvailable;
}

class FirebaseConnectionService {
  const FirebaseConnectionService();

  Future<FirebaseConnection> initialize({
    required FirebaseOptions options,
  }) async {
    final app = await Firebase.initializeApp(options: options);

    FirebaseAuth.instanceFor(app: app);
    FirebaseFirestore.instanceFor(app: app);

    return const FirebaseConnection.initialized();
  }
}
