# 詳細設計

## 計算要件

### 外部重量推定負荷

```text
estimatedLoadKg = externalWeightKg
```

ダンベル:

```text
totalExternalLoadKg = loadPerSideKg × numberOfLoads
```

### 自重推定負荷

```text
estimatedLoadKg
= bodyWeightKg × bodyWeightLoadRatio
+ addedWeightKg
- assistanceWeightKg
```

記号:

```text
L = BW × C + A - S
```

- L: 推定負荷
- BW: 体重
- C: 自重負荷係数
- A: 追加重量
- S: 補助重量

### セットボリューム

```text
setVolumeKg = estimatedLoadKg × reps
```

### セッションボリューム

```text
sessionVolumeKg = Σ setVolumeKg
```

### RIR 補正ボリューム

```text
effortAdjustedVolume = setVolumeKg × rirMultiplier
```

標準係数:

| RIR | 係数 |
|---:|---:|
| 0 | 1.00 |
| 1 | 1.00 |
| 2 | 0.95 |
| 3 | 0.85 |
| 4 | 0.70 |
| 5 | 0.50 |
| 6 以上 | 0.30 |
| 不明 | 0.70 |

これは比較用の独自ルールとする。

### ハードセット判定

```text
RIR 0〜4   → true
RIR 5以上 → false
RIR null  → null
```

### 対象筋配分

```text
muscleAllocatedValue = effortAdjustedVolume × muscleAllocation
```

例:

```text
ベンチプレス
胸           1.0
上腕三頭筋   0.5
前三角筋     0.5
```

配分合計は 1.0 を超えてよい。

### 比較項目

- 推定ボリューム
- RIR 補正ボリューム
- ハードセット数
- 対象筋一致度
- 限界への近さ
- 可動域
- 種目特異性
- 前回比
- 前週比

単一の筋肥大スコアは MVP では採用しない。

## 計算設定要件

ログインユーザー全員が利用可能。

### 自重係数

設定方法:

- 標準値
- 手動入力
- 体重計測定値

体重計による個人係数:

```text
coefficient = measuredSupportedWeight / bodyWeight
```

上下姿勢を測定した場合:

```text
coefficient = ((topLoad + bottomLoad) / 2) / bodyWeight
```

### RIR 係数

標準設定を複製し、ユーザーが変更できる。

### 対象筋配分

種目ごとに編集可能。

### 適用範囲

- 今後の記録へ適用
- 過去履歴表示も新設定で再計算

元のセット記録は変更しない。

## Firebase 詳細設計

### Firebase Authentication

方式:

- Google
- Email/Password

メール確認は必須にしない。

### Cloud Firestore 構造

```text
users/{userId}
├── profile/main
├── settings/main
├── workoutSessions/{sessionId}
├── workoutPlans/{planId}
├── customExercises/{exerciseId}
├── calculationSettings/{settingId}
├── aiExportHistories/{exportId}
└── devices/{deviceId}
```

### Cloud Functions

MVP では以下に限定する。

- アカウント全データ削除
- 複雑な競合解決
- 大規模 JSON インポート

通常 CRUD は Firestore SDK で行う。

### Security Rules

基本条件:

```text
request.auth != null
request.auth.uid == userId
```

必須制約:

- 未認証ユーザーはユーザーデータへアクセス不可
- 他ユーザーのデータを閲覧不可
- 他ユーザーのデータを更新不可
- `ownerUserId` 変更不可
- `createdAt` 変更不可
- `schemaVersion` 変更不可
- 不正な重量、回数、RIR、係数を拒否

## フロントエンド詳細設計

### レイヤー

```text
Presentation
↓
Application
↓
Domain
↓
Data
```

### Presentation

- Flutter Widget
- Riverpod
- フォーム
- 画面遷移
- 保存状態表示

### Application

- ログイン
- プロフィール保存
- セッション開始
- セット保存
- セッション完了
- AI 出力生成
- 次回予定作成

### Domain

- モデル
- 値オブジェクト
- バリデーション
- 計算
- 比較
- Exporter

### Data

- Firebase Authentication
- Cloud Firestore
- Cloud Functions
- JSON 入出力

## 重要な境界

### Repository

UI や Domain から Firebase SDK を隔離する。

### Clock

現在時刻を直接呼ばず、テスト時に固定可能とする。

### Calculator

計算を Firebase・Widget から分離する。

### Exporter

Markdown・JSON 生成を独立させる。

## Repository インターフェース

### AuthRepository

```dart
abstract interface class AuthRepository {
  Stream<AuthUser?> watchAuthState();

  Future<AuthUser> signInWithGoogle();

  Future<AuthUser> registerWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();
}
```

### WorkoutRepository

```dart
abstract interface class WorkoutRepository {
  Future<WorkoutSession> create(WorkoutSession session);

  Future<void> saveDraft(WorkoutSession session);

  Future<void> complete(WorkoutSession session);

  Future<WorkoutSession?> findById(String sessionId);

  Future<List<WorkoutSession>> findByPeriod({
    required DateTime from,
    required DateTime to,
  });

  Stream<List<WorkoutSession>> watchRecent();

  Future<void> update(WorkoutSession session);

  Future<void> delete(String sessionId);

  Future<void> restore(String sessionId);
}
```

### CalculationSettingsRepository

```dart
abstract interface class CalculationSettingsRepository {
  Future<List<CalculationSettings>> findAll();

  Future<CalculationSettings> findDefault();

  Future<void> save(CalculationSettings settings);

  Future<void> setDefault(String settingId);

  Future<void> delete(String settingId);
}
```

### AiExportRepository

```dart
abstract interface class AiExportRepository {
  Future<void> save(AiExportHistory history);

  Future<List<AiExportHistory>> findAll();

  Future<AiExportHistory?> findById(String id);

  Future<void> updateMemo(String id, String memo);

  Future<void> delete(String id);
}
```

## Riverpod 状態管理

### 方針

Notifier は同期的な UI 状態を扱う。

- 入力フォーム
- RIR 選択
- 即時計算
- 表示切替

AsyncNotifier は非同期処理を扱う。

- 認証
- Firestore 保存
- 履歴取得
- AI 履歴保存
- 次回予定保存

### Provider 一覧

| Provider | 種類 | 責務 |
|---|---|---|
| authControllerProvider | AsyncNotifier | 認証 |
| profileControllerProvider | AsyncNotifier | プロフィール |
| workoutFormProvider | Notifier | 入力状態 |
| workoutCalculationProvider | Provider | 即時計算 |
| workoutSaveProvider | AsyncNotifier | Firestore 保存 |
| workoutHistoryProvider | AsyncNotifier | 履歴 |
| calculationSettingsProvider | AsyncNotifier | 計算設定 |
| aiExportFormProvider | Notifier | AI 依頼条件 |
| aiExportGeneratorProvider | Provider | Markdown / JSON |
| aiExportHistoryProvider | AsyncNotifier | AI 履歴 |
| planControllerProvider | AsyncNotifier | 次回予定 |
| pendingWritesProvider | StreamProvider | 同期待ち状態 |
| connectivityProvider | StreamProvider | 通信状態 |
| clockProvider | Provider | 現在時刻 |
| appEnvironmentProvider | Provider | dev/stg/prod |

## 画面一覧

### 認証・プロフィール

- ログイン
- アカウント登録
- パスワード再設定
- 初回プロフィール設定

### ホーム

- 今日の予定
- 記録開始
- 最近の記録
- 今週の集計
- 最近の AI 出力
- 保存状態

### トレーニング

- セッション開始
- 種目選択
- セット入力
- 自重詳細
- 外部重量詳細
- コンディション
- 完了確認
- 記録結果
- 下書き復元

### 履歴・比較

- 履歴一覧
- セッション詳細
- セッション編集
- 週間集計
- 比較対象選択
- 基準メニュー入力
- 比較結果

### AI

- AI 依頼設定
- 対象範囲選択
- Markdown プレビュー
- JSON プレビュー
- AI 履歴一覧
- AI 履歴詳細
- AI 回答メモ

### 次回予定

- 予定一覧
- 予定作成
- 予定編集
- 予定からセッション開始

### 設定・データ

- 種目一覧
- カスタム種目
- 計算設定一覧
- 自重係数
- RIR 係数
- 対象筋配分
- JSON エクスポート
- JSON インポート
- アカウント設定
- アカウント削除

## 開発者・管理機能

### 本番管理画面

作成しない。

本番運用には以下を利用する。

- Firebase Console
- Authentication 管理
- Firestore 確認
- Functions ログ
- Crashlytics
- App Check
- 使用量・予算アラート

### 開発用画面

development/staging 限定で用意できる。

- Firebase UID
- 認証プロバイダー
- 保存状態
- Firestore 接続先
- 計算バージョン
- プロンプトバージョン
- 計算トレース

production ではルートを登録しない。
