import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'email_registration_controller.dart';
import '../data/auth_repository.dart';

final emailLoginControllerProvider =
    AsyncNotifierProvider<EmailLoginController, EmailLoginState>(
      EmailLoginController.new,
    );

class EmailLoginState {
  const EmailLoginState({
    this.isLoggedIn = false,
    this.errorMessage,
  });

  final bool isLoggedIn;
  final String? errorMessage;
}

class EmailLoginController extends AsyncNotifier<EmailLoginState> {
  @override
  EmailLoginState build() => const EmailLoginState();

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    final validationMessage = _validate(
      email: normalizedEmail,
      password: password,
    );

    if (validationMessage != null) {
      state = AsyncData(EmailLoginState(errorMessage: validationMessage));
      return false;
    }

    state = const AsyncLoading();

    try {
      await ref
          .read(authRepositoryProvider)
          .loginWithEmailAndPassword(
            email: normalizedEmail,
            password: password,
          );
      ref.read(authSessionProvider.notifier).markAuthenticated();
      state = const AsyncData(EmailLoginState(isLoggedIn: true));
      return true;
    } on AuthFailure catch (error) {
      state = AsyncData(EmailLoginState(errorMessage: error.message));
      return false;
    }
  }

  String? _validate({
    required String email,
    required String password,
  }) {
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(email)) {
      return 'メールアドレスの形式を確認してください';
    }

    if (password.isEmpty) {
      return 'パスワードを入力してください';
    }

    return null;
  }
}
