import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/auth/application/email_registration_controller.dart';
import 'package:volume_fit/src/features/auth/application/google_login_controller.dart';
import 'package:volume_fit/src/features/auth/data/auth_repository.dart';

void main() {
  test('marks the session authenticated after Google login succeeds', () async {
    final repository = FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(googleLoginControllerProvider.notifier)
        .login();

    expect(succeeded, isTrue);
    expect(repository.googleLoginCallCount, 1);
    expect(container.read(authSessionProvider), isTrue);
    expect(container.read(googleLoginControllerProvider).value?.isLoggedIn, isTrue);
  });

  test('shows Google login failure and keeps session unauthenticated', () async {
    final repository = FakeAuthRepository(
      failure: const AuthFailure('Googleログインに失敗しました'),
    );
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(googleLoginControllerProvider.notifier)
        .login();

    expect(succeeded, isFalse);
    expect(repository.googleLoginCallCount, 1);
    expect(container.read(authSessionProvider), isFalse);
    expect(
      container.read(googleLoginControllerProvider).value?.errorMessage,
      'Googleログインに失敗しました',
    );
  });
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.failure});

  final AuthFailure? failure;
  int googleLoginCallCount = 0;

  @override
  Future<AuthUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> loginWithGoogle() async {
    googleLoginCallCount += 1;

    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }

    return const AuthUser(
      uid: 'google-uid-1',
      email: 'user@example.com',
      emailVerified: true,
    );
  }
}
