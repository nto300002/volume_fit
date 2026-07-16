# データモデル

## 保存要件

### 正規保存先

```text
Source of Truth = Cloud Firestore
```

ユーザーデータの正式な保存先は Cloud Firestore だけとする。

### ローカル正式 DB

使用しない。

削除対象:

- Drift
- SQLite
- IndexedDB の直接管理
- 独自ローカル同期キュー
- ローカル DB マイグレーション

### Firestore SDK キャッシュ

Firestore SDK 内部のキャッシュ・保留書き込みは補助的に利用可能とする。

これは正式な独自ローカル DB とは扱わない。

### 保存状態

```text
idle
saving
pending
saved
offline_pending
failed
conflict
```

### 保存完了表示

| 状態 | 表示 |
|---|---|
| `saved` | クラウド保存済み |
| `pending` | 同期待ち |
| `offline_pending` | オフライン・通信復旧後に保存 |
| `failed` | 保存に失敗しました / 再試行 |

保存失敗時もフォーム内容を保持する。

## Firestore 構造

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

## UserProfile

```json
{
  "schemaVersion": 1,
  "ownerUserId": "uid",
  "displayName": "ユーザー",
  "heightCm": 178.0,
  "currentBodyWeightKg": 80.0,
  "trainingExperienceMonths": 24,
  "primaryGoal": "hypertrophy",
  "unitSystem": "metric",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "revision": 1
}
```

## WorkoutSession

```json
{
  "schemaVersion": 1,
  "ownerUserId": "uid",
  "status": "completed",
  "goal": "hypertrophy",
  "startedAt": "timestamp",
  "completedAt": "timestamp",
  "condition": {
    "bodyWeightKg": 80.0,
    "sleepMinutes": 390,
    "fatigueLevel": 3,
    "sorenessLevel": 2,
    "painStatus": "none",
    "painLocation": null,
    "memo": null
  },
  "exercises": [],
  "exerciseIds": [],
  "calculationSettingId": "setting-id",
  "sessionMemo": null,
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "revision": 1,
  "isDeleted": false,
  "deletedAt": null
}
```

## ExerciseLog

```json
{
  "exerciseLogId": "exercise-log-id",
  "exerciseId": "push_up",
  "displayName": "腕立て伏せ",
  "resistanceType": "body_weight",
  "variation": "standard",
  "targetMuscles": [
    {
      "muscleId": "chest",
      "allocation": 1.0
    }
  ],
  "sets": [],
  "memo": null
}
```

## WorkoutSet

```json
{
  "setId": "set-id",
  "order": 1,
  "externalWeightKg": null,
  "bodyWeightKg": 80.0,
  "bodyWeightLoadRatio": 0.72,
  "addedWeightKg": 0.0,
  "assistanceWeightKg": 0.0,
  "reps": 12,
  "rir": 2,
  "result": "completed",
  "rangeOfMotion": "full",
  "tempo": null,
  "restSeconds": null,
  "memo": null
}
```

## CalculationSettings

```json
{
  "schemaVersion": 1,
  "ownerUserId": "uid",
  "name": "標準設定",
  "baseVersion": "standard-v1",
  "bodyweightCoefficients": {
    "push_up.standard": 0.72
  },
  "rirMultipliers": {
    "0": 1.0,
    "1": 1.0,
    "2": 0.95,
    "3": 0.85,
    "4": 0.70,
    "unknown": 0.70
  },
  "muscleAllocations": {
    "push_up": {
      "chest": 1.0,
      "triceps": 0.5,
      "front_deltoid": 0.5
    }
  },
  "isDefault": true,
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "revision": 1
}
```

## AiExportHistory

```json
{
  "schemaVersion": 1,
  "ownerUserId": "uid",
  "targetSessionIds": [
    "session-id"
  ],
  "referenceSessionId": null,
  "purpose": "daily_review",
  "targetAiService": "chatgpt",
  "markdownContent": "...",
  "jsonContent": {},
  "calculationVersion": "standard-v1",
  "promptVersion": "prompt-v1",
  "calculationSnapshot": {},
  "customInstruction": null,
  "aiResponseMemo": null,
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "revision": 1,
  "isDeleted": false
}
```

## 計算結果保存方針

### 通常セッション

保存する:

- 元の入力値
- 使用した係数
- 計算設定 ID
- 計算バージョン

通常は保存しない:

- 推定負荷
- 推定ボリューム
- RIR 補正値
- 対象筋別集計

表示時に再計算する。

### AI 出力履歴

AI へ渡した内容の再現性を確保するため、生成時点の計算結果をスナップショット保存する。
