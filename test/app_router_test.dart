import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/app/app_router.dart';
import 'package:volume_fit/src/features/auth/application/email_registration_controller.dart';

void main() {
  test('defines the main route paths', () {
    expect(AppRoutePaths.login, '/login');
    expect(AppRoutePaths.home, '/');
    expect(AppRoutePaths.profile, '/profile');
    expect(AppRoutePaths.workout, '/workout');
    expect(AppRoutePaths.history, '/history');
    expect(AppRoutePaths.historyDetail('session-1'), '/history/session-1');
    expect(AppRoutePaths.planNew, '/plans/new');
    expect(AppRoutePaths.ai, '/ai');
    expect(AppRoutePaths.settings, '/settings');
  });

  test('auth state defaults to unauthenticated', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(isAuthenticatedProvider), isFalse);
  });

  test('uses the bootstrapped Firebase authentication state', () {
    final container = ProviderContainer(
      overrides: [initialAuthSessionProvider.overrideWithValue(true)],
    );
    addTearDown(container.dispose);

    expect(container.read(isAuthenticatedProvider), isTrue);
  });
}
