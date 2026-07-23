# Issue 019: Firestore の保存状態を表示

## 対象

- GitHub Issue: #20
- Issue 定義: [019-show-firestore-save-status.md](../../issue/019-show-firestore-save-status.md)
- 対象機能: セット保存時の保存状態表示と失敗時の再試行

## 自動テスト確認

- [x] 保存成功時に `保存済みです` を表示する
- [x] 同期待ち時に `同期待ちです` を表示する
- [x] オフライン保留時に `オフライン保留中です` を表示する
- [x] 保存失敗時にエラーメッセージを表示する
- [x] 保存失敗時にフォーム内容を保持する
- [x] 保存失敗時に `再試行` アクションを表示する
- [x] 再試行時に保持した入力内容で再保存する

## 手動確認

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | 腕立て伏せ 1 セットを保存する | 保存後に `保存済みです` が表示される | Widget テストで確認 |
| 2 | 保存処理が pending を返す | `同期待ちです` が表示される | Widget テストで確認 |
| 3 | 保存処理が offline pending を返す | `オフライン保留中です` が表示される | Widget テストで確認 |
| 4 | 保存処理が失敗する | 入力値を保持したまま `保存に失敗しました` と `再試行` が表示される | Widget / Controller テストで確認 |
| 5 | 失敗後に再試行する | 保持した入力値で保存し直す | Controller テストで確認 |
| 6 | 実ブラウザで通信断と再試行を確認する | 状態表示と再試行が期待どおりに動作する | 未実施 |

## 未実施理由

実ブラウザでの通信断 / Firestore Emulator を使ったオフライン保留確認は、Firebase Emulator Suite と通信断シナリオの実行環境がこの issue の範囲では未整備のため未実施。UI 表示と再試行動作は repository の結果を差し替えた Widget / Controller テストで検証した。

## 実行コマンド

- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test test/workout_set_input_controller_test.dart test/widget_test.dart`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter analyze`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test`

## 結果

- `flutter analyze`: 成功
- `flutter test`: 成功

## 対象外

- Firestore Emulator または本番 Firebase プロジェクトの環境構築
- Firestore metadata の購読によるリアルタイム同期状態反映
- 通信復旧後の pending writes 自動反映表示
