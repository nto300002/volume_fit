import 'package:flutter/material.dart';

import 'src/app/app_environment.dart';
import 'src/app/volume_fit_app.dart';

void main() {
  runApp(VolumeFitApp(environment: AppEnvironmentConfig.current()));
}

typedef MyApp = VolumeFitApp;
