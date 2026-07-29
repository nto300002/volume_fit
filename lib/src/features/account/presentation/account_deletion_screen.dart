import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../application/account_deletion_controller.dart';

class AccountDeletionScreen extends ConsumerWidget {
  const AccountDeletionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletion = ref.watch(accountDeletionControllerProvider);
    final state = deletion.value;
    final isDeleting = deletion.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('アカウント削除')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'アカウントと保存済みデータを完全に削除します。',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('この操作は取り消せません。'),
                if (state?.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    state!.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('deleteAccountButton'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: isDeleting
                      ? null
                      : () => _confirmDeletion(context, ref),
                  child: isDeleting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('アカウントを削除'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeletion(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('アカウントを削除しますか？'),
        content: const Text('トレーニング履歴、設定、AI出力履歴を含むすべてのデータが削除されます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            key: const Key('confirmDeleteAccountButton'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('削除する'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    final succeeded = await ref
        .read(accountDeletionControllerProvider.notifier)
        .deleteAccount();
    if (succeeded && context.mounted) {
      context.go(AppRoutePaths.login);
    }
  }
}
