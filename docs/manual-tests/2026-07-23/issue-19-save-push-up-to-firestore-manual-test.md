# Issue 018: 腕立て伏せ 1 セットを Firestore へ保存

## 対象

- GitHub Issue: #19
- Issue 定義: [018-save-push-up-one-set.md](../../issue/018-save-push-up-one-set.md)
- 対象機能: 入力した腕立て伏せ 1 セットを `WorkoutSession` として Firestore に保存する

## 自動テスト確認

- [x] `WorkoutSession / ExerciseLog / WorkoutSet` 構造に沿った payload を保存する
- [x] 体重、体重負荷係数、追加重量、補助重量、回数、RIR の元入力値を保存する
- [x] `estimatedLoadKg` / `setVolumeKg` / `effortAdjustedVolume` は通常セッションへ永続化しない
- [x] 未ログイン状態では保存を拒否する
- [x] UI の保存操作から体重と体重負荷係数を repository へ渡す

## 手動確認

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | ログイン済み状態でホームからトレーニング入力画面を開く | 腕立て伏せの 1 セット入力フォームが表示される | 自動 Widget テストで確認 |
| 2 | 種目に腕立て伏せ、体重 80kg、回数 12、RIR 2 を入力して保存する | `users/{uid}/workoutSessions` に 1 件追加する保存処理が呼ばれる | Repository テストで確認 |
| 3 | 保存 payload を確認する | 元入力値と係数を含み、計算結果は含まない | Repository テストで確認 |
| 4 | 未ログイン状態で保存する | 保存せずエラーにする | Repository テストで確認 |
| 5 | Firestore Console または Emulator で実データを確認する | `workoutSessions` に期待構造で保存される | 未実施 |

## 未実施理由

Firestore Console / Emulator を使った実データ確認は、Firebase プロジェクト接続情報および Emulator Suite の起動設定がこの issue の実装範囲では未整備のため未実施。保存先パスと payload は `WorkoutSessionWriter` を差し替えた Repository テストで検証した。

## 実行コマンド

- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter analyze`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test`

## 結果

- `flutter analyze`: 成功
- `flutter test`: 成功

## 対象外

- 保存中 / 保存完了 / 保存失敗の UI 表示
- Firestore Emulator または本番 Firebase プロジェクトの環境構築
- 通常セッションへの計算結果の永続化
