import 'package:firebase_core/firebase_core.dart';

import '../app/app_environment.dart';

FirebaseOptions firebaseOptionsFor(AppEnvironmentConfig config) {
  return switch (config.environment) {
    AppEnvironment.development => _options(
      projectId: 'training-ai-dev',
      appId: '1:100000000001:web:volume-fit-dev',
      messagingSenderId: '100000000001',
    ),
    AppEnvironment.staging => _options(
      projectId: 'training-ai-stg',
      appId: '1:100000000002:web:volume-fit-stg',
      messagingSenderId: '100000000002',
    ),
    AppEnvironment.production => _options(
      projectId: 'training-ai-prod',
      appId: '1:100000000003:web:volume-fit-prod',
      messagingSenderId: '100000000003',
    ),
  };
}

FirebaseOptions _options({
  required String projectId,
  required String appId,
  required String messagingSenderId,
}) {
  // Replace these placeholder values with FlutterFire CLI output per project.
  return FirebaseOptions(
    apiKey: 'replace-with-$projectId-web-api-key',
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    authDomain: '$projectId.firebaseapp.com',
    storageBucket: '$projectId.firebasestorage.app',
  );
}
