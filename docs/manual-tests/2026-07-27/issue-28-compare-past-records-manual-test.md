# Issue 027: 過去記録と比較できる

## 対象

- GitHub Issue: #28
- Issue 定義: [027-compare-past-records.md](../../issue/027-compare-past-records.md)
- 対象機能: セッション詳細で過去記録との比較を表示する

## 自動テスト確認

- [x] 対象セッションの直前セッションを比較対象として取得する
- [x] 推定ボリュームの差分を表示できる
- [x] RIR 補正ボリュームの差分を表示できる
- [x] ハードセット数の差分を表示できる
- [x] 対象筋一致度を表示できる
- [x] セッション詳細画面に `前回比` と比較結果を表示できる

## 手動確認

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | 履歴一覧からセッション詳細を開く | 詳細画面に比較ブロックが表示される | Widget テストで確認 |
| 2 | 前回記録がある状態で詳細を確認する | 推定ボリューム、RIR 補正、ハードセット、対象筋一致度が表示される | Repository / Widget テストで確認 |
| 3 | 比較対象がない状態を確認する | 比較ブロックなしで詳細表示できる | 既存詳細テストで確認 |
| 4 | Firestore 実データで比較表示を確認する | 保存済みデータ同士で期待どおり比較される | 未実施 |

## 未実施理由

Firestore Console / Emulator を使った実データ確認は、この issue の範囲では未実施。比較対象取得、差分計算、詳細画面表示は Repository / Widget テストで検証済み。

## 実行コマンド

- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test test/workout_history_repository_test.dart test/widget_test.dart`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter analyze`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test`

## 結果

- `flutter analyze`: 成功
- `flutter test`: 成功

## 対象外

- 前週比の専用 UI
- 基準メニュー入力 UI
- 比較対象の手動選択
- 可動域、限界への近さ、種目特異性の詳細比較
