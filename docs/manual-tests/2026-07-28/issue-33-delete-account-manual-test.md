# Issue 032: アカウントを削除できる

## 対象

- GitHub Issue: #33
- Issue 定義: [032-delete-account.md](../../issue/032-delete-account.md)
- 対象機能: 確認操作後に Cloud Functions でアカウントとユーザーデータを削除する

## 自動テスト確認

- [x] 削除ボタンの前に確認ダイアログを表示する
- [x] キャンセル時は削除リポジトリを呼び出さない
- [x] 確認後は Callable Function を通じて削除する
- [x] 削除成功時はローカル認証状態を解除しログイン画面へ戻る
- [x] 削除失敗時は認証状態を維持してエラーを表示する
- [x] Cloud Function の Node.js 構文を検証する

## 手動確認

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | アカウント削除を選択する | 確認ダイアログが表示される | Widget テストで確認 |
| 2 | 確認ダイアログでキャンセルする | データ削除を実行しない | Widget テストで確認 |
| 3 | 確認して削除する | ログイン画面へ遷移する | Widget テストで確認 |
| 4 | Firebase Emulator または検証用アカウントで削除する | Firestore 配下と Authentication ユーザーが削除される | 未実施 |

## 未実施理由

この操作はアカウントと全データを復元不能に削除するため、Firebase Emulator または専用の検証用アカウントを用意した後に実施する。通常の開発アカウントや実利用アカウントでは実行しない。

## 実行コマンド

- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test test/account_deletion_controller_test.dart test/account_deletion_screen_test.dart`
- `node --check functions/index.js`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter analyze`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test`

## 対象外

- 削除前の再認証 UI。Callable Function が再認証を要求した場合はエラーを表示する
- 削除データの復元
- Firebase Emulator の自動 E2E テスト。Firebase プロジェクト配備後の後続検証で対応する
