# Volume Fit Documentation

Volume Fit の要件定義・詳細設計・状態遷移・開発計画をまとめたドキュメントです。

## ドキュメント一覧

| ファイル | 内容 |
|---|---|
| [requirements.md](requirements.md) | MVP 要件定義、プロダクト責務、利用者要件、対象運動、AI 出力要件 |
| [detailed-design.md](detailed-design.md) | Flutter/Firebase 詳細設計、Repository 境界、Riverpod 方針、画面一覧 |
| [data-model.md](data-model.md) | Firestore 構造、データモデル、計算結果保存方針 |
| [state-transitions.md](state-transitions.md) | 認証、保存、セッション、メイン画面遷移の状態遷移図 |
| [ui-mock.md](ui-mock.md) | 主要画面、画面遷移、Riverpod 構成の UI モック |
| [deployment-environments.md](deployment-environments.md) | 本番環境、環境分離、デプロイ順序、Preview Channel、公開ゲート |
| [development-plan.md](development-plan.md) | 実装フェーズ、TDD 方針、Issue 運用、初期 Issue 構成、MVP 完成条件 |
| [issue/README.md](issue/README.md) | 設計文書から抽出した Issue 一覧と各 Issue のチェックリスト |

## MVP の中心価値

Volume Fit は、筋トレ記録をアプリ内で閉じた分析にするのではなく、外部 AI が解釈しやすい Markdown / JSON へ整形するためのアプリです。

```text
筋トレを記録
↓
アプリ内で推定負荷・ボリューム等を計算
↓
ChatGPT・Claude 向け Markdown / JSON を生成
↓
ユーザーが AI へ手動共有
↓
AI が評価・比較・次回メニューを提案
↓
AI が Notion 保存用 Markdown を生成
↓
ユーザーが Notion へ手動保存
↓
AI の次回提案をアプリへ手動登録
```
