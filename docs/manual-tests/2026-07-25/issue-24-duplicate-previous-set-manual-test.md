# Issue 023: 前セットを複製

## 対象

- GitHub Issue: #24
- Issue 定義: [023-duplicate-previous-set.md](../../issue/023-duplicate-previous-set.md)
- 対象機能: 直前セットを複製し、複製後に編集して保存する

## 自動テスト確認

- [x] 直前セットの体重、係数、追加重量、補助重量、回数、RIR を引き継ぐ
- [x] 複製セットに新しい `order` を付与する
- [x] 保存時に `set-1`, `set-2` のような別 `setId` として保存される
- [x] 複製後に回数と RIR を編集できる
- [x] 複製元がない場合はエラーを表示する
- [x] UI から直前セットを複製して編集・保存できる

## 手動確認

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | 1 セット目を追加後、`直前セットを複製` を押す | `セット 2` が同じ主要値で追加される | Widget / Controller テストで確認 |
| 2 | 複製したセットを編集する | `order` は 2 のまま、回数・RIR が更新される | Widget テストで確認 |
| 3 | 保存する | 複製元と複製先が別セットとして保存される | Widget / Repository 既存テストで確認 |
| 4 | 複製元がない状態で複製する | 複製せずエラーになる | Controller テストで確認 |
| 5 | Firestore Console または Emulator で実データを確認する | 複製したセットが別 `setId` として保存される | 未実施 |

## 未実施理由

Firestore Console / Emulator を使った実データ確認は、Firebase プロジェクト接続情報および Emulator Suite の起動設定がこの issue の範囲では未整備のため未実施。保存 payload の `setId` と `order` は既存 Repository テストで検証済み。

## 実行コマンド

- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test test/workout_set_input_controller_test.dart test/widget_test.dart`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter analyze`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test`

## 結果

- `flutter analyze`: 成功
- `flutter test`: 成功

## 対象外

- セット削除
- 複数種目をまたぐ複製
- 保存済み履歴からのセット複製
- Firestore Emulator または本番 Firebase プロジェクトの環境構築
