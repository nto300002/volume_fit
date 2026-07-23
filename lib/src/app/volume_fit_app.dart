import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';

class VolumeFitApp extends ConsumerWidget {
  const VolumeFitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Volume Fit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F62FE)),
        fontFamily: 'HiraginoKakuGothic',
        fontFamilyFallback: const [
          'Hiragino Sans',
          'Noto Sans CJK JP',
          'Noto Sans JP',
          'sans-serif',
        ],
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
