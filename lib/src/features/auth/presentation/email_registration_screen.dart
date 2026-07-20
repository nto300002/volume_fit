import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../application/email_login_controller.dart';
import '../application/email_registration_controller.dart';

class EmailRegistrationScreen extends ConsumerStatefulWidget {
  const EmailRegistrationScreen({super.key});

  @override
  ConsumerState<EmailRegistrationScreen> createState() =>
      _EmailRegistrationScreenState();
}

class _EmailRegistrationScreenState
    extends ConsumerState<EmailRegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registration = ref.watch(emailRegistrationControllerProvider);
    final registrationState = registration.value;
    final login = ref.watch(emailLoginControllerProvider);
    final loginState = login.value;
    final isSubmitting = registration.isLoading || login.isLoading;
    final errorMessage =
        loginState?.errorMessage ?? registrationState?.errorMessage;

    return Scaffold(
      appBar: AppBar(title: const Text('ログイン')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ログイン',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'メールアドレスとパスワードで続けます。登録後もメール確認は必須にしません。',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    key: const Key('emailRegistrationEmailField'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'メールアドレス',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('emailRegistrationPasswordField'),
                    controller: _passwordController,
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    onSubmitted: (_) => _submitLogin(context),
                    decoration: const InputDecoration(
                      labelText: 'パスワード',
                      helperText: '6文字以上',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (errorMessage != null) ...[
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  FilledButton(
                    onPressed: isSubmitting ? null : () => _submitLogin(context),
                    child: isSubmitting && login.isLoading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('メールでログイン'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: isSubmitting
                        ? null
                        : () => _submitRegistration(context),
                    child: isSubmitting
                        && registration.isLoading
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('メールで登録'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitLogin(BuildContext context) async {
    final succeeded = await ref
        .read(emailLoginControllerProvider.notifier)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    _goToProfileWhenAuthenticated(succeeded);
  }

  Future<void> _submitRegistration(BuildContext context) async {
    final succeeded = await ref
        .read(emailRegistrationControllerProvider.notifier)
        .register(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    _goToProfileWhenAuthenticated(succeeded);
  }

  void _goToProfileWhenAuthenticated(bool succeeded) {
    if (succeeded && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(AppRoutePaths.profile);
        }
      });
    }
  }
}
