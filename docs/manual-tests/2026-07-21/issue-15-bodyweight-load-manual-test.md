# Issue 014: 自重推定負荷を計算できる 手動テスト記録

## 対象

- GitHub Issue: #15
- 実装 Issue: Issue 014: 自重推定負荷を計算できる
- ブランチ: `codex/issue-15-bodyweight-load`

## 確認内容

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | 腕立て伏せを選択し、体重 80 kg を入力する | 標準係数 0.72 により 57.6 kg と表示される | OK |
| 2 | 体重 80 kg、係数 0.72、追加重量 5 kg、補助重量 10 kg で計算する | `80 * 0.72 + 5 - 10 = 52.6 kg` になる | OK |
| 3 | 係数 1.2 を指定する | 不正な係数として拒否される | OK |

## 自動テスト

- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter analyze`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test`

## 対象外

- Firestore からのユーザー別計算設定取得
- 計算設定の編集 UI
- セット保存時の推定負荷永続化
