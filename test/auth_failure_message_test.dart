import 'package:flutter_test/flutter_test.dart';
import 'package:volume_fit/src/features/auth/data/auth_repository.dart';

void main() {
  group('loginFailureMessageForCode', () {
    test('identifies an invalid Firebase API key', () {
      expect(
        loginFailureMessageForCode('api-key-not-valid'),
        'Firebase の接続設定が正しくありません。管理者にお問い合わせください',
      );
    });

    test('identifies an invalid API key', () {
      expect(
        loginFailureMessageForCode('invalid-api-key'),
        'Firebase の接続設定が正しくありません。管理者にお問い合わせください',
      );
    });

    test('identifies a rate-limited sign-in attempt', () {
      expect(
        loginFailureMessageForCode('too-many-requests'),
        '試行回数が多すぎます。しばらくしてから再度お試しください',
      );
    });

    test('identifies a disabled user', () {
      expect(
        loginFailureMessageForCode('user-disabled'),
        'このアカウントは無効化されています。管理者にお問い合わせください',
      );
    });
  });

  group('registrationFailureMessageForCode', () {
    test('identifies administrator-restricted sign-up', () {
      expect(
        registrationFailureMessageForCode('admin-restricted-operation'),
        '現在、新規アカウント登録は利用できません。管理者にお問い合わせください',
      );
    });
  });
}
