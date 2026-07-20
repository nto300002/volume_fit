import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'email_registration_controller.dart';
import '../data/auth_repository.dart';

final googleLoginControllerProvider =
    AsyncNotifierProvider<GoogleLoginController, GoogleLoginState>(
      GoogleLoginController.new,
    );

class GoogleLoginState {
  const GoogleLoginState({
    this.isLoggedIn = false,
    this.errorMessage,
  });

  final bool isLoggedIn;
  final String? errorMessage;
}

class GoogleLoginController extends AsyncNotifier<GoogleLoginState> {
  @override
  GoogleLoginState build() => const GoogleLoginState();

  Future<bool> login() async {
    state = const AsyncLoading();

    try {
      await ref.read(authRepositoryProvider).loginWithGoogle();
      ref.read(authSessionProvider.notifier).markAuthenticated();
      state = const AsyncData(GoogleLoginState(isLoggedIn: true));
      return true;
    } on AuthFailure catch (error) {
      state = AsyncData(GoogleLoginState(errorMessage: error.message));
      return false;
    }
  }
}
