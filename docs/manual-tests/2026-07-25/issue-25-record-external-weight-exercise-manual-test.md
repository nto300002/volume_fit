# Issue 024: 外部重量種目を記録できる

## 対象

- GitHub Issue: #25
- Issue 定義: [024-record-external-weight-exercise.md](../../issue/024-record-external-weight-exercise.md)
- 対象機能: バーベル、ダンベル等の外部重量種目をセット入力画面から記録する

## 自動テスト確認

- [x] 外部重量種目は体重・自重負荷係数なしで保存できる
- [x] ベンチプレスは入力重量をそのまま推定負荷として扱う
- [x] ダンベル種目は片側重量と個数から合計負荷を計算する
- [x] 0 kg 以下の外部重量は保存前に拒否する
- [x] Firestore payload に `externalWeightKg` と `resistanceType: external_weight` を保存する
- [x] 既存の腕立て伏せ入力、複数セット、複製、保存状態表示が継続して動作する

## 手動確認

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | ベンチプレスを選択し、重量 60 kg / 10 回 / RIR 2 を入力する | 推定負荷が `60.0 kg` と表示される | Widget テストで確認 |
| 2 | ベンチプレスを保存する | 保存済みになり、`externalWeightKg: 60` として保存 draft が作られる | Widget / Controller / Repository テストで確認 |
| 3 | ダンベルカールを選択し、片側 22.5 kg / 個数 2 を入力する | 推定負荷が `45.0 kg` と表示される | Widget / Controller / Domain テストで確認 |
| 4 | 外部重量 0 kg で保存する | 保存せず、重量のエラーを表示する | Controller / Domain テストで確認 |
| 5 | 実ブラウザでベンチプレスとダンベルカールを操作する | 表示・入力・保存が期待どおりに動作する | 未実施 |

## 未実施理由

実ブラウザでの手動操作はこの turn では未実施。UI 操作、保存 draft、Firestore payload 形状は Widget / Controller / Repository テストで検証済み。

## 実行コマンド

- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test test/external_weight_load_calculator_test.dart test/workout_set_input_controller_test.dart test/workout_set_input_repository_test.dart test/widget_test.dart`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter analyze`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test`

## 結果

- `flutter analyze`: 成功
- `flutter test`: 成功

## 対象外

- 外部重量種目のカスタム登録
- 種目ごとの詳細な対象筋編集
- 保存済み履歴画面での外部重量表示
- Firestore Emulator または本番 Firebase プロジェクトの環境構築
