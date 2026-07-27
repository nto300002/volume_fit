# Issue 026: セッション詳細を表示できる

## 対象

- GitHub Issue: #27
- Issue 定義: [026-show-session-detail.md](../../issue/026-show-session-detail.md)
- 対象機能: セッション内の種目・セット・計算結果を詳細表示する

## 自動テスト確認

- [x] WorkoutSession を ID で取得する
- [x] 論理削除済み、または存在しないセッション詳細を表示しない
- [x] セットごとに推定負荷、セットボリューム、RIR 補正ボリュームを再計算する
- [x] 履歴一覧からセッション詳細へ遷移できる
- [x] 概算値の注意文を表示する

## 手動確認

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | 履歴一覧で保存済みセッションを選択する | セッション詳細画面へ遷移する | Widget テストで確認 |
| 2 | 詳細画面を確認する | 種目名、セット、回数、RIR、再計算値が表示される | Widget / Repository テストで確認 |
| 3 | 自重種目の詳細を読み込む | 推定負荷、セットボリューム、RIR 補正が再計算される | Repository テストで確認 |
| 4 | 存在しないセッション ID を読み込む | エラーとして扱う | Repository テストで確認 |
| 5 | Firestore 実データで詳細表示を確認する | 保存済みセッションの詳細が期待どおり表示される | 未実施 |

## 未実施理由

Firestore Console / Emulator を使った実データ確認は、この issue の範囲では未実施。ID 取得、再計算、詳細画面表示、概算注意文は Repository / Controller / Widget テストで検証済み。

## 実行コマンド

- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test test/workout_history_repository_test.dart test/workout_history_controller_test.dart test/widget_test.dart`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter analyze`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test`

## 結果

- `flutter analyze`: 成功
- `flutter test`: 成功

## 対象外

- セッション詳細からの編集・削除
- セット単位のメモ編集
- 複数種目の追加操作
- Firestore Emulator または本番 Firebase プロジェクトの環境構築
