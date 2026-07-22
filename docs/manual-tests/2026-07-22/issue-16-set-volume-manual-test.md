# Issue 015: セットボリュームを計算できる 手動テスト記録

## 対象

- GitHub Issue: #16
- 実装 Issue: Issue 015: セットボリュームを計算できる
- ブランチ: `codex/issue-16-set-volume`

## 確認内容

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | 推定負荷 57.6 kg、回数 12 を入力する | `57.6 * 12 = 691.2 kg` と表示される | OK |
| 2 | 推定負荷 57.6 kg、回数 0 を計算する | セットボリューム 0 kg になる | OK |
| 3 | 回数 -1 を指定する | 不正な回数として拒否される | OK |

## 自動テスト

- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter analyze`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test`

## 対象外

- セットボリュームの Firestore 永続化
- セッション合計ボリュームの集計
- RIR 補正ボリューム
