import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/app_environment.dart';
import 'src/app/volume_fit_app.dart';
import 'src/firebase/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: firebaseOptionsFor(AppEnvironmentConfig.current()),
  );

  runApp(const ProviderScope(child: VolumeFitApp()));
}

typedef MyApp = VolumeFitApp;
