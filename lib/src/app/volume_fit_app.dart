import 'package:flutter/material.dart';

import '../features/home/presentation/home_screen.dart';

class VolumeFitApp extends StatelessWidget {
  const VolumeFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volume Fit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F62FE)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
