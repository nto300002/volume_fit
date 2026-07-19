import 'package:flutter/material.dart';

import 'app_environment.dart';
import '../features/home/presentation/home_screen.dart';

class VolumeFitApp extends StatelessWidget {
  const VolumeFitApp({super.key, required this.environment});

  final AppEnvironmentConfig environment;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volume Fit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F62FE)),
        useMaterial3: true,
      ),
      home: HomeScreen(environment: environment),
    );
  }
}
