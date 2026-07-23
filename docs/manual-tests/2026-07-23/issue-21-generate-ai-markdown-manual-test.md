# Issue 020: AI 用 Markdown を生成

## 対象

- GitHub Issue: #21
- Issue 定義: [020-generate-ai-markdown.md](../../issue/020-generate-ai-markdown.md)
- 対象機能: 記録内容と計算値から AI に渡す Markdown を生成する

## 自動テスト確認

- [x] 記録上確認できる事実と推定を分ける指示を含める
- [x] 不明情報を創作しない指示を含める
- [x] アプリ計算値が比較用の概算である注意文を含める
- [x] 推定ボリュームを筋肥大効果と同一視しない注意文を含める
- [x] 次回メニューの出力条件を含める
- [x] Notion へ保存しやすい Markdown 出力の指示を含める
- [x] 記録内容と計算値を Markdown プレビューに表示する
- [x] RIR とハードセット判定が不明な場合は不明として出力する

## 手動確認

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | ホームから AI 出力画面を開く | `AI出力` 画面が表示される | Widget テストで確認 |
| 2 | 体重 80kg、回数 12、RIR 2 を入力して Markdown 生成する | Markdown プレビューが表示される | Widget テストで確認 |
| 3 | 生成 Markdown を確認する | 事実、概算値、AI への共通指示、次回メニュー、Notion Markdown 指示を含む | Unit / Widget テストで確認 |
| 4 | 生成文を ChatGPT / Claude に貼り付ける | 実用的な評価と次回メニューが返る | 未実施 |

## 未実施理由

ChatGPT / Claude への貼り付けによる実用性確認は、外部 AI サービスへの手動操作が必要なため未実施。生成文の必須構造と文言は Unit / Widget テストで検証した。

## 実行コマンド

- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test test/ai_markdown_generator_test.dart test/widget_test.dart`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter analyze`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test`

## 結果

- `flutter analyze`: 成功
- `flutter test`: 成功

## 対象外

- AI 出力履歴の Firestore 保存
- 履歴一覧から対象セッションを選択する UI
- OS 共有シート
- JSON 出力
