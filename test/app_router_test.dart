import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/app/app_router.dart';

void main() {
  test('defines the main route paths', () {
    expect(AppRoutePaths.login, '/login');
    expect(AppRoutePaths.home, '/');
    expect(AppRoutePaths.profile, '/profile');
    expect(AppRoutePaths.workout, '/workout');
    expect(AppRoutePaths.history, '/history');
    expect(AppRoutePaths.ai, '/ai');
    expect(AppRoutePaths.settings, '/settings');
  });

  test('auth state defaults to unauthenticated', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(isAuthenticatedProvider), isFalse);
  });
}
