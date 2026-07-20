import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/email_registration_controller.dart';
import '../features/auth/presentation/email_registration_screen.dart';
import '../features/home/presentation/home_screen.dart';

class AppRoutePaths {
  const AppRoutePaths._();

  static const login = '/login';
  static const home = '/';
  static const profile = '/profile';
  static const workout = '/workout';
  static const history = '/history';
  static const ai = '/ai';
  static const settings = '/settings';
}

final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authSessionProvider),
);

final initialLocationProvider = Provider<String>((ref) => AppRoutePaths.home);

final appRouterProvider = Provider<GoRouter>((ref) {
  final initialLocation = ref.watch(initialLocationProvider);

  return GoRouter(
    initialLocation: initialLocation,
    redirect: (context, state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final isLoginRoute = state.matchedLocation == AppRoutePaths.login;

      if (!isAuthenticated && !isLoginRoute) {
        return AppRoutePaths.login;
      }

      if (isAuthenticated && isLoginRoute) {
        return AppRoutePaths.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutePaths.login,
        builder: (context, state) => const EmailRegistrationScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutePaths.profile,
        builder: (context, state) =>
            const RoutePlaceholderScreen(title: 'プロフィール'),
      ),
      GoRoute(
        path: AppRoutePaths.workout,
        builder: (context, state) =>
            const RoutePlaceholderScreen(title: 'トレーニング'),
      ),
      GoRoute(
        path: AppRoutePaths.history,
        builder: (context, state) => const RoutePlaceholderScreen(title: '履歴'),
      ),
      GoRoute(
        path: AppRoutePaths.ai,
        builder: (context, state) => const RoutePlaceholderScreen(title: 'AI'),
      ),
      GoRoute(
        path: AppRoutePaths.settings,
        builder: (context, state) => const RoutePlaceholderScreen(title: '設定'),
      ),
    ],
  );
});

class RoutePlaceholderScreen extends StatelessWidget {
  const RoutePlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
