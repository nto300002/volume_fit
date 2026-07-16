# Volume Fit

筋トレ記録を、ChatGPT・Claude などの外部 AI が読み取りやすい形式へ整形するためのトレーニング記録アプリです。

本アプリは、トレーニング分析をアプリ内だけで完結させるのではなく、記録・計算・比較・AI 共有用データ生成を担い、外部 AI による評価や次回メニュー提案につなげることを目的とします。

## Documentation

- [docs/README.md](docs/README.md): ドキュメント目次
- [docs/requirements.md](docs/requirements.md): 要件定義
- [docs/detailed-design.md](docs/detailed-design.md): 詳細設計
- [docs/data-model.md](docs/data-model.md): データモデル
- [docs/state-transitions.md](docs/state-transitions.md): 状態遷移図
- [docs/ui-mock.md](docs/ui-mock.md): UI モック
- [docs/deployment-environments.md](docs/deployment-environments.md): 本番環境・デプロイ設計
- [docs/development-plan.md](docs/development-plan.md): 開発計画
- [docs/issue/README.md](docs/issue/README.md): Issue 一覧

## MVP 方針

| 項目 | 内容 |
|---|---|
| アプリ種別 | 筋トレ記録・AI 連携支援アプリ |
| 対象運動 | 外部重量トレーニング、自重トレーニング |
| MVP 対象外 | 有酸素運動 |
| 実装順 | Web/PWA → Android |
| フロントエンド | Flutter |
| 状態管理 | Riverpod |
| ルーティング | go_router |
| 認証 | Firebase Authentication |
| 正規データ保存先 | Cloud Firestore |
| サーバー処理 | Cloud Functions |
| AI 連携 | ChatGPT・Claude 等へ手動共有 |
| Notion 連携 | AI 生成 Markdown を手動貼り付け |
| 開発手法 | TDD |

## プロダクトの流れ

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

## アプリの責務

- トレーニングの事実を記録する
- 自重運動の負荷を概算する
- ボリューム、RIR 補正値、ハードセット等を計算する
- 過去記録や基準メニューと比較する
- AI が読みやすい入力文を生成する
- AI へ渡した内容を履歴保存する
- AI 提案の次回予定を手動管理する

## 外部 AI の責務

- 記録内容の解釈
- 前回との差の評価
- 疲労・停滞要因の推定
- 自重と外部重量の比較
- 次回メニュー作成
- Notion 保存用文章の生成

## 最重要の価値検証要件

### 入力の負担を下げる

トレーニング中に記録が煩雑にならないことを重視します。

初期検証フロー:

```text
ログイン済み
↓
腕立て伏せを選択
↓
回数を入力
↓
RIR を選択
↓
保存
```

目標:

- 1 セット目の主要操作を 4 操作程度に抑える
- 2 セット目以降は「前セット複製」を利用する
- 入力後、計算結果を即時表示する
- 保存失敗時も入力内容を保持する

### 概算値であることを明示する

推定負荷やボリュームは、実際の筋肥大量や筋力向上量を直接示すものではありません。

主要な計算画面・AI 出力には、次の趣旨を表示します。

> この値はトレーニング比較用の概算です。実際の筋肥大量や筋力向上量を直接示すものではありません。

### AI 出力の実用性を検証する

生成 Markdown を実際に ChatGPT・Claude へ渡し、次を確認します。

- 記録内容を正しく理解できる
- 概算値を絶対的効果として扱わない
- 次回メニューが具体的に出る
- Notion 用文章がそのまま利用できる
- 毎回追記する指示がないか確認できる

## 主な機能

### 認証・プロフィール

- ログイン必須
- Google ログイン
- メールアドレス + パスワード
- パスワード再設定
- 初回プロフィール設定
- メール確認は必須にしない

プロフィール項目:

- 表示名
- 身長
- 体重
- トレーニング経験月数
- 主要目的
- 使用単位 kg 固定

主要目的:

- 筋肥大
- 筋力向上
- その他

### トレーニング記録

対象運動:

- バーベル
- ダンベル
- マシン
- ケーブル
- プレートロード式器具
- 腕立て伏せ
- 懸垂
- ディップス
- 自重スクワット
- ブルガリアンスクワット
- ランジ

自重バリエーション:

- 通常
- 膝つき
- インクライン
- デクライン
- 加重

### 計算

- 外部重量推定負荷
- 自重推定負荷
- セットボリューム
- セッションボリューム
- RIR 補正ボリューム
- ハードセット判定
- 対象筋配分
- 過去記録・基準メニューとの比較

### AI 出力

対象 AI:

- ChatGPT
- Claude
- その他 Markdown / JSON を解釈できる AI

出力形式:

- Markdown
- JSON
- Notion 保存用 Markdown

共有方法:

- クリップボードコピー
- テキスト共有
- 履歴保存

## 保存方針

正規保存先は Cloud Firestore です。

ローカル正式 DB は使用せず、Firestore SDK の保留書き込み・キャッシュを補助的に利用します。

保存状態:

- `saved`: 保存完了
- `pending`: 保存処理中
- `offline_pending`: オフライン保留中
- `failed`: 保存失敗

## Firebase 設計

使用サービス:

- Firebase Authentication
- Cloud Firestore
- Cloud Functions
- Security Rules

主なデータモデル:

- `UserProfile`
- `WorkoutSession`
- `ExerciseLog`
- `WorkoutSet`
- `CalculationSettings`
- `AiExportHistory`

## フロントエンド設計

レイヤー:

- Presentation
- Application
- Domain
- Data

重要な境界:

- Repository
- Clock
- Calculator
- Exporter

主な Repository:

- `AuthRepository`
- `WorkoutRepository`
- `CalculationSettingsRepository`
- `AiExportRepository`

## 画面一覧

- 認証
- プロフィール
- ホーム
- トレーニング記録
- 履歴・比較
- AI 出力
- 次回予定
- 設定
- 開発環境限定画面

本番用の独自管理画面は MVP では作成しません。

## 実装フェーズ

### Phase 1: Web 縦切り

- Flutter Web 基盤
- Firebase 接続
- 認証
- プロフィール
- 腕立て伏せ 1 セット記録
- 保存
- 計算
- AI 出力

### Phase 2: Web MVP

- 外部重量種目
- 自重バリエーション
- セット複製
- 履歴
- 比較
- AI 出力履歴
- 次回予定

### Phase 3: PWA

- PWA 対応
- オフライン保留表示
- モバイル Web 操作性調整

### Phase 4: Android

- Android ビルド
- Firebase Android 設定
- 実機確認

## テスト方針

TDD を基本方針とします。

テスト対象:

- Unit テスト
- Repository テスト
- Widget テスト
- Integration テスト

Issue 完了条件:

- 自動テスト
- 手動テスト
- 結果記録

## MVP 完成条件

Web/PWA:

- ログインしてプロフィールを設定できる
- トレーニングセッションを作成できる
- 外部重量・自重セットを記録できる
- 推定負荷・ボリューム・RIR 補正値を確認できる
- AI 共有用 Markdown / JSON を生成できる
- AI 出力履歴を保存できる
- 次回予定を手動登録できる
- 保存状態を確認できる

Android:

- Android 実機で主要フローが動作する
- Firebase 認証・Firestore 保存が動作する
- Web/PWA と同じデータを扱える
