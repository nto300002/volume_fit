import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/app_providers.dart';
import 'firebase_connection.dart';
import 'firebase_options.dart';

final firebaseOptionsProvider = Provider<FirebaseOptions>((ref) {
  final environment = ref.watch(appEnvironmentProvider);
  return firebaseOptionsFor(environment);
});

final firebaseConnectionServiceProvider = Provider<FirebaseConnectionService>(
  (ref) => const FirebaseConnectionService(),
);

final firebaseConnectionProvider = FutureProvider<FirebaseConnection>((ref) {
  final options = ref.watch(firebaseOptionsProvider);
  final service = ref.watch(firebaseConnectionServiceProvider);

  return service.initialize(options: options);
});
