import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(FirebaseAuth.instance),
);

abstract interface class AuthRepository {
  Future<AuthUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AuthUser> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AuthUser> loginWithGoogle();

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> signOut();
}

class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.emailVerified,
  });

  final String uid;
  final String email;
  final bool emailVerified;
}

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;
}

class FirebaseAuthRepository implements AuthRepository {
  const FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  Future<AuthUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user == null) {
        throw const AuthFailure('登録に失敗しました。時間をおいて再度お試しください');
      }

      return AuthUser(
        uid: user.uid,
        email: user.email ?? email,
        emailVerified: user.emailVerified,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_registrationMessageForCode(error.code));
    }
  }

  @override
  Future<AuthUser> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user == null) {
        throw const AuthFailure('メールアドレスまたはパスワードが正しくありません');
      }

      return AuthUser(
        uid: user.uid,
        email: user.email ?? email,
        emailVerified: user.emailVerified,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_loginMessageForCode(error.code));
    }
  }

  @override
  Future<AuthUser> loginWithGoogle() async {
    try {
      final provider = GoogleAuthProvider();
      provider.addScope('email');
      provider.addScope('profile');

      final credential = await _auth.signInWithPopup(provider);
      final user = credential.user;

      if (user == null) {
        throw const AuthFailure('Googleログインに失敗しました');
      }

      return AuthUser(
        uid: user.uid,
        email: user.email ?? '',
        emailVerified: user.emailVerified,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_googleLoginMessageForCode(error.code));
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_passwordResetMessageForCode(error.code));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException {
      throw const AuthFailure('ログアウトに失敗しました');
    }
  }

  String _registrationMessageForCode(String code) {
    return switch (code) {
      'invalid-email' => 'メールアドレスの形式を確認してください',
      'weak-password' => 'パスワードは6文字以上で入力してください',
      'email-already-in-use' => 'このメールアドレスはすでに登録されています',
      'operation-not-allowed' => 'メールアドレス登録が有効になっていません',
      'network-request-failed' => '通信に失敗しました。接続を確認してください',
      _ => '登録に失敗しました。時間をおいて再度お試しください',
    };
  }

  String _loginMessageForCode(String code) {
    return switch (code) {
      'invalid-email' => 'メールアドレスの形式を確認してください',
      'invalid-credential' ||
      'user-not-found' ||
      'wrong-password' => 'メールアドレスまたはパスワードが正しくありません',
      'operation-not-allowed' => 'メールアドレス登録が有効になっていません',
      'network-request-failed' => '通信に失敗しました。接続を確認してください',
      _ => 'ログインに失敗しました。時間をおいて再度お試しください',
    };
  }

  String _googleLoginMessageForCode(String code) {
    return switch (code) {
      'popup-closed-by-user' ||
      'cancelled-popup-request' => 'Googleログインがキャンセルされました',
      'account-exists-with-different-credential' => '同じメールアドレスの別ログイン方法が登録されています',
      'operation-not-allowed' => 'Googleログインが有効になっていません',
      'network-request-failed' => '通信に失敗しました。接続を確認してください',
      _ => 'Googleログインに失敗しました',
    };
  }

  String _passwordResetMessageForCode(String code) {
    return switch (code) {
      'invalid-email' => 'メールアドレスの形式を確認してください',
      'user-not-found' => '登録済みメールアドレスを確認してください',
      'network-request-failed' => '通信に失敗しました。接続を確認してください',
      _ => 'パスワード再設定メールの送信に失敗しました',
    };
  }
}
