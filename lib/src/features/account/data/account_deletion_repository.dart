import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountDeletionRepositoryProvider = Provider<AccountDeletionRepository>(
  (ref) => FirebaseAccountDeletionRepository(FirebaseFunctions.instance),
);

abstract interface class AccountDeletionRepository {
  Future<void> deleteAccount();
}

class FirebaseAccountDeletionRepository implements AccountDeletionRepository {
  const FirebaseAccountDeletionRepository(this._functions);

  final FirebaseFunctions _functions;

  @override
  Future<void> deleteAccount() async {
    try {
      await _functions.httpsCallable('deleteAccount').call<void>();
    } on FirebaseFunctionsException catch (error) {
      throw AccountDeletionFailure(_messageForCode(error.code));
    } catch (_) {
      throw const AccountDeletionFailure('アカウント削除に失敗しました');
    }
  }

  String _messageForCode(String code) {
    return switch (code) {
      'unauthenticated' => 'ログイン状態を確認してください',
      'failed-precondition' => 'アカウントを再認証してから削除してください',
      'unavailable' => '通信に失敗しました。接続を確認してください',
      _ => 'アカウント削除に失敗しました',
    };
  }
}

class AccountDeletionFailure implements Exception {
  const AccountDeletionFailure(this.message);

  final String message;
}
