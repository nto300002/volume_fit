import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/auth/application/email_login_controller.dart';
import 'package:volume_fit/src/features/auth/application/email_registration_controller.dart';
import 'package:volume_fit/src/features/auth/data/auth_repository.dart';

void main() {
  test('rejects invalid email before calling repository', () async {
    final repository = FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(emailLoginControllerProvider.notifier)
        .login(email: 'invalid-email', password: 'Password1');

    expect(succeeded, isFalse);
    expect(repository.loginCallCount, 0);
    expect(
      container.read(emailLoginControllerProvider).value?.errorMessage,
      'メールアドレスの形式を確認してください',
    );
  });

  test('shows authentication failure and keeps session unauthenticated', () async {
    final repository = FakeAuthRepository(
      failure: const AuthFailure('メールアドレスまたはパスワードが正しくありません'),
    );
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(emailLoginControllerProvider.notifier)
        .login(email: 'user@example.com', password: 'wrong-password');

    expect(succeeded, isFalse);
    expect(repository.loginCallCount, 1);
    expect(container.read(authSessionProvider), isFalse);
    expect(
      container.read(emailLoginControllerProvider).value?.errorMessage,
      'メールアドレスまたはパスワードが正しくありません',
    );
  });

  test('marks the session authenticated after login succeeds', () async {
    final repository = FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(emailLoginControllerProvider.notifier)
        .login(email: 'user@example.com', password: 'Password1');

    expect(succeeded, isTrue);
    expect(repository.loginCallCount, 1);
    expect(container.read(authSessionProvider), isTrue);
    expect(container.read(emailLoginControllerProvider).value?.isLoggedIn, isTrue);
  });
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.failure});

  final AuthFailure? failure;
  int loginCallCount = 0;

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
  }) async {
    loginCallCount += 1;

    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }

    return AuthUser(uid: 'uid-1', email: email, emailVerified: false);
  }

  @override
  Future<AuthUser> loginWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    throw UnimplementedError();
  }
}
