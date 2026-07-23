# Issue 017: ハードセットを判定できる 手動テスト記録

## 対象

- GitHub Issue: #18
- 実装 Issue: Issue 017: ハードセットを判定できる
- ブランチ: `codex/issue-18-hard-set-judgement`

## 確認内容

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | RIR 0〜4 を判定する | ハードセットとして `true` になる | OK |
| 2 | RIR 5、10 を判定する | 通常セットとして `false` になる | OK |
| 3 | RIR 未選択を判定する | 不明として `null` になる | OK |
| 4 | RIR -1 を指定する | 不正な RIR として拒否される | OK |
| 5 | セット入力画面で RIR 4 を選択する | `ハードセット判定` と `ハードセット` が表示される | OK |

## 自動テスト

- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter analyze`
- `/Users/naotoyasuda/Documents/New project/horen-check/toolchains/flutter/bin/flutter test`

## 対象外

- ハードセット判定結果の Firestore 永続化
- 履歴・比較画面でのハードセット集計
- ユーザーごとのハードセット閾値変更
