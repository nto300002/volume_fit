# Issue 031: JSON インポートできる

## 対象

- GitHub Issue: #32
- Issue 定義: [031-json-import.md](../../issue/031-json-import.md)
- 対象機能: Volume Fit JSON を検証してトレーニング履歴へ取り込む

## 自動テスト確認

- [x] `schemaVersion: 1` と `volume_fit_ai_export` 形式だけを受理する
- [x] セッション、種目、セットの必須値と境界値を検証する
- [x] 不正 JSON、未対応バージョン、不正なセットを拒否する
- [x] 100 セッションまたは 1,000 セットを超える JSON を拒否する
- [x] 取り込み後のセッションをログインユーザーの `workoutSessions` へ保存する
- [x] AI 出力画面から JSON を入力し、成功・失敗メッセージを表示する

## 手動確認

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | AI 出力画面へ正規 JSON を入力して取り込む | セッション数の完了メッセージが表示される | Widget テストで確認 |
| 2 | 不正な JSON を入力して取り込む | 形式エラーを表示し、保存しない | Widget テストで確認 |
| 3 | 未対応 schemaVersion または不正なセットを取り込む | 理由を表示し、保存しない | Unit テストで確認 |
| 4 | 100 セッションまたは 1,000 セット超の JSON を取り込む | 大量データは拒否する | Unit テストで確認 |
| 5 | 実ブラウザでログイン後に正規 JSON を取り込む | Firestore の履歴へ反映される | 未実施 |

## 未実施理由

ローカル開発サーバーは `http://127.0.0.1:3001` で起動済み。実ブラウザでの Firestore 書き込みには認証済みの検証用アカウントが必要なため、この記録では保存を伴う手動操作を実施していない。

## 実行コマンド

- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test test/ai_json_importer_test.dart test/ai_json_import_repository_test.dart test/ai_json_import_screen_test.dart`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter analyze`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test`

## 対象外

- JSON ファイル選択による読み込み
- 1,000 セット超の大量データ取り込み。Cloud Functions を使う後続 Issue で対応する
- 既存履歴との重複検知・マージ
- エクスポート元に含まれない日時の復元。取り込み時刻を `completedAt` として記録する
