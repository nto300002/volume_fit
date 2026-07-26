# Issue 025: 履歴一覧を表示できる

## 対象

- GitHub Issue: #26
- Issue 定義: [025-show-workout-history-list.md](../../issue/025-show-workout-history-list.md)
- 対象機能: 過去のトレーニングセッションを一覧表示する

## 自動テスト確認

- [x] 最近の記録を取得する
- [x] 期間指定の取得条件を Repository / Controller に渡せる
- [x] 論理削除済みのセッションを通常表示から除外する
- [x] セッション内の種目名、セット数、総ボリュームを一覧表示できる
- [x] 履歴が空の場合は空状態を表示する
- [x] ホーム画面から履歴画面へ遷移できる

## 手動確認

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | ホーム画面で `履歴を見る` を押す | 履歴画面へ遷移する | Widget テストで確認 |
| 2 | 複数件の履歴を表示する | 種目名、日付、セット数、総ボリュームが表示される | Widget / Repository テストで確認 |
| 3 | 履歴が 0 件の状態で開く | `まだ記録がありません` と表示される | Widget テストで確認 |
| 4 | 期間指定で取得する | `from` / `to` 条件つきで履歴取得できる | Controller / Repository テストで確認 |
| 5 | Firestore 実データで最近順を確認する | 複数日の記録が正しい順序で表示される | 未実施 |

## 未実施理由

Firestore Console / Emulator を使った実データ確認は、この issue の範囲では未実施。取得条件、論理削除除外、表示内容は Repository / Controller / Widget テストで検証済み。

## 実行コマンド

- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test test/workout_history_repository_test.dart test/workout_history_controller_test.dart test/widget_test.dart`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter analyze`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test`

## 結果

- `flutter analyze`: 成功
- `flutter test`: 成功

## 対象外

- 履歴詳細画面
- 履歴からの編集・削除
- カレンダー UI による任意期間選択
- Firestore Indexes の追加管理
