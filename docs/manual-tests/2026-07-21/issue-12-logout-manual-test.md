# Issue 011 ログアウト 手動画面表示テスト

## 実施日

2026-07-21

## 対象

- PR #66: Issue 011 ログアウトを追加
- ローカルURL: `http://127.0.0.1:3001`

## 確認結果

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | 未認証でアプリを開く | ログイン画面が表示される | 成功 |
| 2 | メールアドレスとパスワードでログインする | プロフィール画面へ遷移する | 失敗 |
| 3 | ログアウトする | ログイン画面へ戻る | 未実施 |
| 4 | Firebase初期化修正後に未認証でアプリを開く | ログイン画面が表示される | 成功 |
| 5 | Firebase初期化修正後にメールログインを試す | ローディングで固まらず、失敗時はエラー表示へ戻る | 成功 |

## スクリーンショット

- `issue-12-login-screen.png`
- `issue-12-email-login-attempt-result.png`
- `issue-12-after-fix-login-screen.png`
- `issue-12-after-fix-startup-result.png`
- `issue-12-after-fix-email-login-attempt.png`

## 補足

ログイン操作時に `FirebaseAuth.instance` がFirebase初期化前に参照され、Providerがエラー状態になった。
このためログイン後画面とログアウト後画面の手動確認は未実施。

修正方針:

- `main()` でFirebaseをアプリ起動前に初期化する。
- 修正後にログイン操作がローディングで固まらず、Firebase Authの通常エラー表示へ戻ることを確認する。

## 修正後の結果

`main()` でFirebaseを起動前に初期化した後、ログイン画面の表示とメールログイン失敗時のエラー表示を確認した。

実Firebaseプロジェクト・APIキー・Auth設定がまだプレースホルダーのため、実ログイン成功、ログイン後画面、ログアウト戻りの手動確認は未実施。
これらは FlutterFire 設定と development Firebase プロジェクト構築後に再確認する。
