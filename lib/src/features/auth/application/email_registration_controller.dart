import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

final authSessionProvider = NotifierProvider<AuthSessionController, bool>(
  AuthSessionController.new,
);

final emailRegistrationControllerProvider =
    AsyncNotifierProvider<
      EmailRegistrationController,
      EmailRegistrationState
    >(EmailRegistrationController.new);

class EmailRegistrationState {
  const EmailRegistrationState({
    this.isRegistered = false,
    this.errorMessage,
  });

  final bool isRegistered;
  final String? errorMessage;
}

class AuthSessionController extends Notifier<bool> {
  @override
  bool build() => false;

  void markAuthenticated() {
    state = true;
  }
}

class EmailRegistrationController
    extends AsyncNotifier<EmailRegistrationState> {
  @override
  EmailRegistrationState build() => const EmailRegistrationState();

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    final validationMessage = _validate(
      email: normalizedEmail,
      password: password,
    );

    if (validationMessage != null) {
      state = AsyncData(EmailRegistrationState(errorMessage: validationMessage));
      return false;
    }

    state = const AsyncLoading();

    try {
      await ref
          .read(authRepositoryProvider)
          .registerWithEmailAndPassword(
            email: normalizedEmail,
            password: password,
          );
      ref.read(authSessionProvider.notifier).markAuthenticated();
      state = const AsyncData(EmailRegistrationState(isRegistered: true));
      return true;
    } on AuthFailure catch (error) {
      state = AsyncData(EmailRegistrationState(errorMessage: error.message));
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

    if (password.length < 6) {
      return 'パスワードは6文字以上で入力してください';
    }

    return null;
  }
}
