# Issue 021: AI 出力履歴を Firestore へ保存

## 対象

- GitHub Issue: #22
- Issue 定義: [021-save-ai-export-history.md](../../issue/021-save-ai-export-history.md)
- 対象機能: AI へ渡した Markdown / JSON と計算スナップショットを履歴保存する

## 自動テスト確認

- [x] `AiExportHistory` モデルに沿った payload を作成する
- [x] `users/{uid}/aiExportHistories` へ保存する writer を用意する
- [x] `markdownContent` と `jsonContent` を保存する
- [x] `calculationVersion` と `promptVersion` を保存する
- [x] `calculationSnapshot` に推定負荷、セットボリューム、RIR 補正ボリュームを保存する
- [x] `aiResponseMemo` は `null` とし、AI 回答自体は自動取得しない
- [x] 未ログイン状態では保存を拒否する
- [x] AI 出力画面から生成済み Markdown を履歴保存できる

## 手動確認

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | AI 出力画面で Markdown を生成する | Markdown プレビューが表示される | Widget テストで確認 |
| 2 | `履歴保存` を押す | `AI出力履歴を保存しました` が表示される | Widget テストで確認 |
| 3 | 保存 payload を確認する | Markdown / JSON / 計算スナップショット / version が保存され、AI 回答は保存されない | Repository テストで確認 |
| 4 | Firestore Console または Emulator で実データを確認する | `aiExportHistories` に期待構造で保存される | 未実施 |
| 5 | AI 出力履歴を一覧・詳細で再確認する | 保存した履歴が再表示される | 未実施 |

## 未実施理由

Firestore Console / Emulator を使った実データ確認は、Firebase プロジェクト接続情報および Emulator Suite の起動設定がこの issue の範囲では未整備のため未実施。履歴一覧・詳細表示は後続 issue の画面実装範囲として扱う。

## 実行コマンド

- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test test/ai_export_history_repository_test.dart test/widget_test.dart`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter analyze`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test`

## 結果

- `flutter analyze`: 成功
- `flutter test`: 成功

## 対象外

- AI 出力履歴の一覧・詳細表示
- Firestore Emulator または本番 Firebase プロジェクトの環境構築
- AI 回答本文の自動取得
- JSON エクスポート機能全体
