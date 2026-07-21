import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/auth/application/email_registration_controller.dart';
import 'package:volume_fit/src/features/auth/application/logout_controller.dart';
import 'package:volume_fit/src/features/auth/data/auth_repository.dart';

void main() {
  test('signs out and clears the authenticated session', () async {
    final repository = FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    container.read(authSessionProvider.notifier).markAuthenticated();

    final succeeded = await container
        .read(logoutControllerProvider.notifier)
        .logout();

    expect(succeeded, isTrue);
    expect(repository.signOutCallCount, 1);
    expect(container.read(authSessionProvider), isFalse);
  });

  test('keeps the session authenticated when sign out fails', () async {
    final repository = FakeAuthRepository(
      failure: const AuthFailure('ログアウトに失敗しました'),
    );
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    container.read(authSessionProvider.notifier).markAuthenticated();

    final succeeded = await container
        .read(logoutControllerProvider.notifier)
        .logout();

    expect(succeeded, isFalse);
    expect(repository.signOutCallCount, 1);
    expect(container.read(authSessionProvider), isTrue);
    expect(
      container.read(logoutControllerProvider).value?.errorMessage,
      'ログアウトに失敗しました',
    );
  });
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.failure});

  final AuthFailure? failure;
  int signOutCallCount = 0;

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
  Future<AuthUser> loginWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    signOutCallCount += 1;

    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
  }
}
