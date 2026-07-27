# Issue 028: 次回予定を登録できる

## 対象

- GitHub Issue: #29
- Issue 定義: [028-create-next-plan.md](../../issue/028-create-next-plan.md)
- 対象機能: ホームから次回予定を手動登録し、AI 出力履歴との関連 ID を保存する

## 自動テスト確認

- [x] 次回予定 Draft から Firestore 保存 payload を生成できる
- [x] `plannedValues` と `actualValues` を分離して保存できる
- [x] `sourceAiExportHistoryId` を任意で保存できる
- [x] 未ログイン時は保存を失敗として扱う
- [x] 入力値の必須チェック、数値範囲チェックを行う
- [x] ホームから次回予定作成画面へ遷移できる
- [x] 画面入力から次回予定を保存できる

## 手動確認

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | ホームで `次回予定を作成` を押す | 次回予定画面が表示される | Widget テストで確認 |
| 2 | 予定日、種目、重量、回数、セット数、目標 RIR を入力して保存する | `次回予定を保存しました` が表示される | Widget テストで確認 |
| 3 | AI 出力履歴 ID を入力して保存する | 保存 payload に `sourceAiExportHistoryId` が含まれる | Repository / Widget テストで確認 |
| 4 | Firestore 実環境で予定データを保存する | `users/{uid}/workoutPlans` に予定データが作成される | 未実施 |
| 5 | 実ブラウザでログイン後に保存する | 画面遷移と保存結果が崩れない | 未実施 |

## 未実施理由

実ブラウザおよび Firestore 実データでの保存確認は、この issue の自動検証後に実施予定。保存 payload の構造、入力バリデーション、画面遷移、保存完了表示は Repository / Controller / Widget テストで検証済み。

## 実行コマンド

- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test test/workout_plan_repository_test.dart test/workout_plan_controller_test.dart test/app_router_test.dart test/widget_test.dart`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter analyze`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test`

## 結果

- `flutter analyze`: 成功
- `flutter test`: 成功

## 対象外

- AI 出力本文からの次回予定自動生成
- 次回予定一覧、編集、削除
- 次回予定からトレーニング記録開始
- 実績入力後の `actualValues` 更新
