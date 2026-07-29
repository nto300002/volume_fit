import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/account/application/account_deletion_controller.dart';
import 'package:volume_fit/src/features/account/data/account_deletion_repository.dart';
import 'package:volume_fit/src/features/auth/application/email_registration_controller.dart';

void main() {
  test(
    'deletes the account and clears the local authenticated session',
    () async {
      final repository = _RecordingAccountDeletionRepository();
      final container = ProviderContainer(
        overrides: [
          accountDeletionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      container.read(authSessionProvider.notifier).markAuthenticated();

      final succeeded = await container
          .read(accountDeletionControllerProvider.notifier)
          .deleteAccount();

      expect(succeeded, isTrue);
      expect(repository.deleteCallCount, 1);
      expect(container.read(authSessionProvider), isFalse);
      expect(
        container.read(accountDeletionControllerProvider).value?.isDeleted,
        isTrue,
      );
    },
  );

  test('keeps the session when account deletion fails', () async {
    final container = ProviderContainer(
      overrides: [
        accountDeletionRepositoryProvider.overrideWithValue(
          _RecordingAccountDeletionRepository(
            failure: const AccountDeletionFailure('アカウント削除に失敗しました'),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.read(authSessionProvider.notifier).markAuthenticated();

    final succeeded = await container
        .read(accountDeletionControllerProvider.notifier)
        .deleteAccount();

    expect(succeeded, isFalse);
    expect(container.read(authSessionProvider), isTrue);
    expect(
      container.read(accountDeletionControllerProvider).value?.errorMessage,
      'アカウント削除に失敗しました',
    );
  });
}

class _RecordingAccountDeletionRepository implements AccountDeletionRepository {
  _RecordingAccountDeletionRepository({this.failure});

  final AccountDeletionFailure? failure;
  int deleteCallCount = 0;

  @override
  Future<void> deleteAccount() async {
    deleteCallCount += 1;
    if (failure != null) {
      throw failure!;
    }
  }
}
