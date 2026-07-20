import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/auth/application/password_reset_controller.dart';
import 'package:volume_fit/src/features/auth/data/auth_repository.dart';

void main() {
  test('rejects invalid email before calling repository', () async {
    final repository = FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(passwordResetControllerProvider.notifier)
        .send(email: 'invalid-email');

    expect(succeeded, isFalse);
    expect(repository.resetCallCount, 0);
    expect(
      container.read(passwordResetControllerProvider).value?.errorMessage,
      'メールアドレスの形式を確認してください',
    );
  });

  test('shows success after password reset email is sent', () async {
    final repository = FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(passwordResetControllerProvider.notifier)
        .send(email: 'user@example.com');

    expect(succeeded, isTrue);
    expect(repository.resetCallCount, 1);
    expect(container.read(passwordResetControllerProvider).value?.isSent, isTrue);
    expect(
      container.read(passwordResetControllerProvider).value?.successMessage,
      'パスワード再設定メールを送信しました',
    );
  });

  test('shows repository failure for unknown or rejected email', () async {
    final repository = FakeAuthRepository(
      failure: const AuthFailure('登録済みメールアドレスを確認してください'),
    );
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(passwordResetControllerProvider.notifier)
        .send(email: 'missing@example.com');

    expect(succeeded, isFalse);
    expect(repository.resetCallCount, 1);
    expect(
      container.read(passwordResetControllerProvider).value?.errorMessage,
      '登録済みメールアドレスを確認してください',
    );
  });
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.failure});

  final AuthFailure? failure;
  int resetCallCount = 0;

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
  Future<void> sendPasswordResetEmail({required String email}) async {
    resetCallCount += 1;

    final failure = this.failure;
    if (failure != null) {
      throw failure;
    }
  }
}
