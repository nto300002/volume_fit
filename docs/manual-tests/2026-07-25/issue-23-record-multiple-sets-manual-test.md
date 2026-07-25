# Issue 022: 複数セットを記録

## 対象

- GitHub Issue: #23
- Issue 定義: [022-record-multiple-sets.md](../../issue/022-record-multiple-sets.md)
- 対象機能: 1 セッション内に複数セットを追加・編集し、まとめて保存する

## 自動テスト確認

- [x] セット追加時に `order` を 1 から順に付与する
- [x] セット編集時に既存の `order` を保持する
- [x] 複数セットを 1 セッションとして保存する
- [x] Firestore payload 内で `set-1`, `set-2` のように安定した `setId` を付与する
- [x] 追加済みセットからセッションボリュームを集計する
- [x] UI で複数セットの追加、編集、保存ができる

## 手動確認

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | 腕立て伏せを選択し、1 セット目を追加する | `セット 1` として一覧に表示される | Widget テストで確認 |
| 2 | 2 セット目を追加する | `セット 2` として一覧に表示される | Widget テストで確認 |
| 3 | 2 セット目を編集する | `order` は 2 のまま、回数と RIR が更新される | Widget / Controller テストで確認 |
| 4 | セッションボリュームを見る | 追加済みセットの合計値が表示される | Widget / Controller テストで確認 |
| 5 | 保存する | 追加済みセットを 1 セッションとして保存する | Widget / Repository テストで確認 |
| 6 | Firestore Console または Emulator で実データを確認する | `sets` 配列に `setId` と `order` が保持される | 未実施 |

## 未実施理由

Firestore Console / Emulator を使った実データ確認は、Firebase プロジェクト接続情報および Emulator Suite の起動設定がこの issue の範囲では未整備のため未実施。保存 payload は writer を差し替えた Repository テストで検証した。

## 実行コマンド

- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test test/workout_set_input_controller_test.dart test/workout_set_input_repository_test.dart test/widget_test.dart`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter analyze`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test`

## 結果

- `flutter analyze`: 成功
- `flutter test`: 成功

## 対象外

- 複数種目をまたぐ 1 セッション入力
- セット削除
- 前セット複製
- Firestore Emulator または本番 Firebase プロジェクトの環境構築
