import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'email_registration_controller.dart';
import '../data/auth_repository.dart';

final logoutControllerProvider =
    AsyncNotifierProvider<LogoutController, LogoutState>(
      LogoutController.new,
    );

class LogoutState {
  const LogoutState({this.isLoggedOut = false, this.errorMessage});

  final bool isLoggedOut;
  final String? errorMessage;
}

class LogoutController extends AsyncNotifier<LogoutState> {
  @override
  LogoutState build() => const LogoutState();

  Future<bool> logout() async {
    state = const AsyncLoading();

    try {
      await ref.read(authRepositoryProvider).signOut();
      ref.read(authSessionProvider.notifier).markUnauthenticated();
      state = const AsyncData(LogoutState(isLoggedOut: true));
      return true;
    } on AuthFailure catch (error) {
      state = AsyncData(LogoutState(errorMessage: error.message));
      return false;
    }
  }
}
