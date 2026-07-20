import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

final passwordResetControllerProvider =
    AsyncNotifierProvider<PasswordResetController, PasswordResetState>(
      PasswordResetController.new,
    );

class PasswordResetState {
  const PasswordResetState({
    this.isSent = false,
    this.successMessage,
    this.errorMessage,
  });

  final bool isSent;
  final String? successMessage;
  final String? errorMessage;
}

class PasswordResetController extends AsyncNotifier<PasswordResetState> {
  @override
  PasswordResetState build() => const PasswordResetState();

  Future<bool> send({required String email}) async {
    final normalizedEmail = email.trim();
    final validationMessage = _validateEmail(normalizedEmail);

    if (validationMessage != null) {
      state = AsyncData(PasswordResetState(errorMessage: validationMessage));
      return false;
    }

    state = const AsyncLoading();

    try {
      await ref
          .read(authRepositoryProvider)
          .sendPasswordResetEmail(email: normalizedEmail);
      state = const AsyncData(
        PasswordResetState(
          isSent: true,
          successMessage: 'パスワード再設定メールを送信しました',
        ),
      );
      return true;
    } on AuthFailure catch (error) {
      state = AsyncData(PasswordResetState(errorMessage: error.message));
      return false;
    }
  }

  String? _validateEmail(String email) {
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(email)) {
      return 'メールアドレスの形式を確認してください';
    }

    return null;
  }
}
