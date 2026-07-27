# Issue 029: カスタム計算設定を作成できる

## 対象

- GitHub Issue: #30
- Issue 定義: [029-custom-calculation-settings.md](../../issue/029-custom-calculation-settings.md)
- 対象機能: 自重係数、RIR 係数、対象筋配分をユーザーのデフォルト計算設定として保存する

## 自動テスト確認

- [x] 標準設定をベースにカスタム設定を作成できる
- [x] デフォルト設定として `users/{uid}/calculationSettings/custom-default` に保存できる
- [x] 自重係数、RIR 係数、対象筋配分を保存 payload に含める
- [x] 保存済みデフォルト設定を読み込める
- [x] 未ログイン時は保存を失敗として扱う
- [x] 自重係数と係数系の境界値を検証する
- [x] 設定画面からカスタム計算設定を保存できる
- [x] 過去履歴の自重種目を現在の計算設定で再計算できる

## 手動確認

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | ホームから `設定` を開く | 計算設定画面が表示される | Widget テストで確認 |
| 2 | 自重係数、RIR 係数、対象筋配分を変更して保存する | `計算設定を保存しました` が表示される | Widget テストで確認 |
| 3 | 自重係数を変更した状態で過去履歴詳細を確認する | 自重種目の推定負荷とボリュームが新設定で再計算される | Repository テストで確認 |
| 4 | Firestore 実環境で保存する | `calculationSettings/custom-default` に保存される | 未実施 |
| 5 | 実ブラウザでログイン後に設定変更する | 画面表示、保存、履歴再計算が崩れない | 未実施 |

## 未実施理由

実ブラウザおよび Firestore 実データでの保存確認は、この issue の自動検証後に実施予定。保存 payload、入力バリデーション、画面操作、履歴再計算は Repository / Controller / Widget テストで検証済み。

## 実行コマンド

- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test test/calculation_settings_repository_test.dart test/calculation_settings_controller_test.dart test/workout_history_repository_test.dart test/widget_test.dart`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter analyze`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test`

## 結果

- `flutter analyze`: 成功
- `flutter test`: 成功

## 対象外

- 複数の計算設定一覧
- 計算設定の編集履歴・復元
- 対象筋配分を使った筋別ボリューム集計
- 体重計測定値からの自動係数算出
- 実機または実ブラウザでの Firestore 保存確認
