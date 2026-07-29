import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/email_registration_controller.dart';
import '../data/account_deletion_repository.dart';

final accountDeletionControllerProvider =
    AsyncNotifierProvider<AccountDeletionController, AccountDeletionState>(
      AccountDeletionController.new,
    );

class AccountDeletionState {
  const AccountDeletionState({this.isDeleted = false, this.errorMessage});

  final bool isDeleted;
  final String? errorMessage;
}

class AccountDeletionController extends AsyncNotifier<AccountDeletionState> {
  @override
  AccountDeletionState build() => const AccountDeletionState();

  Future<bool> deleteAccount() async {
    state = const AsyncLoading();
    try {
      await ref.read(accountDeletionRepositoryProvider).deleteAccount();
      ref.read(authSessionProvider.notifier).markUnauthenticated();
      state = const AsyncData(AccountDeletionState(isDeleted: true));
      return true;
    } on AccountDeletionFailure catch (error) {
      state = AsyncData(AccountDeletionState(errorMessage: error.message));
      return false;
    }
  }
}
