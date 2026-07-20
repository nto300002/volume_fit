import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
        .read(emailRegistrationControllerProvider.notifier)
        .register(email: 'invalid-email', password: 'Password1');

    expect(succeeded, isFalse);
    expect(repository.registerCallCount, 0);
    expect(
      container.read(emailRegistrationControllerProvider).value?.errorMessage,
      'メールアドレスの形式を確認してください',
    );
  });

  test('rejects weak password before calling repository', () async {
    final repository = FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(emailRegistrationControllerProvider.notifier)
        .register(email: 'user@example.com', password: '12345');

    expect(succeeded, isFalse);
    expect(repository.registerCallCount, 0);
    expect(
      container.read(emailRegistrationControllerProvider).value?.errorMessage,
      'パスワードは6文字以上で入力してください',
    );
  });

  test('marks the session authenticated after registration succeeds', () async {
    final repository = FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final succeeded = await container
        .read(emailRegistrationControllerProvider.notifier)
        .register(email: 'user@example.com', password: 'Password1');

    expect(succeeded, isTrue);
    expect(repository.registerCallCount, 1);
    expect(container.read(authSessionProvider), isTrue);
    expect(container.read(emailRegistrationControllerProvider).value?.isRegistered, isTrue);
  });
}

class FakeAuthRepository implements AuthRepository {
  int registerCallCount = 0;

  @override
  Future<AuthUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    registerCallCount += 1;
    return AuthUser(uid: 'uid-1', email: email, emailVerified: false);
  }
}
