# Issue 051: production Preview Channel へ手動配備できる

## Epic

CI/CD・配備

## 概要

production の Preview Channel に手動承認で配備できる。

## 参照設計文書

- [deployment-environments.md](../deployment-environments.md)

## 対象範囲

- [ ] 対象画面・状態を確認する
- [ ] Domain / Application / Repository の影響範囲を確認する
- [ ] Firebase / Firestore / Functions / Hosting の影響範囲を確認する
- [ ] 対象外を Issue または PR に明記する

## 仕様チェックリスト

- [ ] --project training-ai-prod を明示する
- [ ] production 用テストアカウントで確認する
- [ ] live 反映前に検証できる

## TDD チェックリスト

- [ ] 失敗するテストを先に追加した
- [ ] 最小実装でテストを成功させた
- [ ] リファクタリング後もテストが成功する
- [ ] 必要な Unit / Widget / Repository / Integration テストを追加した
- [ ] 境界値・異常系のテストを追加した

## 受け入れ要件

- [ ] 関連する自動テストがすべて成功する
- [ ] `flutter analyze` が成功する
- [ ] Web 実ブラウザまたは対象実機で手動テストした
- [ ] 正常系を手動確認した
- [ ] 異常系を手動確認した
- [ ] 境界値を手動確認した
- [ ] レスポンシブ表示または対象端末表示を確認した
- [ ] コンソールに未対応エラーがない
- [ ] 手動テスト結果を Issue または PR へ記録した
- [ ] 未確認事項が残っていない

## デプロイ確認

- [ ] development 環境で確認した
- [ ] staging 環境へデプロイした
- [ ] staging の実 URL で手動テストした
- [ ] Firebase 接続先が想定環境であることを確認した
- [ ] Firestore Security Rules が期待どおり動作した
- [ ] production 影響の有無を確認した

## production 確認

- [ ] production Preview Channel へデプロイした
- [ ] production 用テストアカウントで確認した
- [ ] production Firebase へ接続していることを確認した
- [ ] development / staging 用表示が含まれていない
- [ ] Developer Tools ルートが存在しない
- [ ] Security Rules・Indexes・Functions を先に配備した
- [ ] ロールバック対象バージョンを確認した
- [ ] 本番手動テスト結果を Issue または PR へ記録した

## 手動テスト

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | production Preview URL で本番接続とデバッグ UI 非搭載を確認する。 | 期待どおりに動作する | 未実施 |
| 2 | 異常系・境界値を確認する | エラー表示または拒否が仕様どおり | 未実施 |

## 完了条件

- [ ] 実装が完了している
- [ ] 自動テストが成功している
- [ ] 手動テストが成功している
- [ ] 手動テスト結果を記録している
- [ ] 未確認事項が残っていない
