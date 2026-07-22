# Issue 016: RIR 補正値を計算できる 手動テスト記録

## 対象

- GitHub Issue: #17
- 実装 Issue: Issue 016: RIR 補正値を計算できる
- ブランチ: `codex/issue-17-rir-adjusted-volume`

## 確認内容

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | セットボリューム 100 kg、RIR 0 を計算する | 係数 1.00 により 100 kg になる | OK |
| 2 | セットボリューム 100 kg、RIR 2 を計算する | 係数 0.95 により 95 kg になる | OK |
| 3 | セットボリューム 100 kg、RIR 4 を計算する | 係数 0.70 により 70 kg になる | OK |
| 4 | セットボリューム 100 kg、RIR 6 を計算する | 係数 0.30 により 30 kg になる | OK |
| 5 | RIR 未選択で計算する | unknown 係数 0.70 が使われる | OK |
| 6 | RIR -1 を指定する | 不正な RIR として拒否される | OK |

## 自動テスト

- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter analyze`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test`

## 対象外

- RIR 係数のユーザー編集 UI
- RIR 補正ボリュームの Firestore 永続化
- ハードセット判定
