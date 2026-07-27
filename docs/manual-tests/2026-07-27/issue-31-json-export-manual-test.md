# Issue 030: JSON エクスポートできる

## 対象

- GitHub Issue: #31
- Issue 定義: [030-json-export.md](../../issue/030-json-export.md)
- 対象機能: AI 出力画面で構造化 JSON を生成し、履歴へ保存する

## 自動テスト確認

- [x] AI 共有・バックアップ向けの構造化 JSON を生成できる
- [x] `schemaVersion`、`format`、目的、計算バージョン、プロンプトバージョンを含める
- [x] セッション、種目、セット、入力値、計算値を JSON に含める
- [x] RIR 不明値を `null` のまま保持し、値を創作しない
- [x] AI 出力画面で JSON プレビューを表示できる
- [x] AI 出力履歴保存時に `jsonContent` へ生成 JSON を保存できる

## 手動確認

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | AI 出力画面で入力して生成する | Markdown と JSON プレビューが表示される | Widget テストで確認 |
| 2 | JSON プレビューの内容を確認する | `volume_fit_ai_export` 形式で入力値・計算値が構造化される | Unit / Widget テストで確認 |
| 3 | AI 出力履歴を保存する | `jsonContent` が空ではなく生成 JSON として保存される | Widget / Repository 既存テストで確認 |
| 4 | 実ブラウザで JSON プレビューを選択・保存する | 画面表示と保存に問題がない | 未実施 |
| 5 | JSON ファイルとしてダウンロードする | ファイルとして保存できる | 対象外 |

## 未実施理由

実ブラウザでのプレビュー確認および Firestore 実データ保存確認は、この issue の自動検証後に実施予定。JSON 生成、プレビュー表示、履歴保存への連携は Unit / Widget テストで検証済み。

## 実行コマンド

- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test test/ai_json_exporter_test.dart test/widget_test.dart`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter analyze`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test`

## 結果

- `flutter analyze`: 成功
- `flutter test`: 成功

## 対象外

- JSON ファイルのダウンロード
- クリップボードコピー
- 対象期間・対象セッションの複数選択 UI
- 履歴一覧からの JSON 再表示
- Android OS 共有シート連携
