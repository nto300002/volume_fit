# Issue 003: Riverpod 基盤を構築する

## Epic

Web 基盤

## 概要

ProviderScope と主要 Provider の土台を作り、画面から状態を watch できるようにする。

## 参照設計文書

- [detailed-design.md](../detailed-design.md)
- [development-plan.md](../development-plan.md)

## 対象範囲

- [ ] 対象画面・状態を確認する
- [ ] Domain / Application / Repository の影響範囲を確認する
- [ ] Firebase / Firestore / Functions / Hosting の影響範囲を確認する
- [ ] 対象外を Issue または PR に明記する

## 仕様チェックリスト

- [ ] ProviderScope がアプリ全体に設定されている
- [ ] Notifier / AsyncNotifier / Provider の配置方針に沿っている
- [ ] clockProvider と appEnvironmentProvider を用意する

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

## 手動テスト

| No. | 操作 | 期待結果 | 結果 |
|---:|---|---|---|
| 1 | サンプル Provider の状態更新が UI に反映されることを確認する。 | 期待どおりに動作する | 未実施 |
| 2 | 異常系・境界値を確認する | エラー表示または拒否が仕様どおり | 未実施 |

## 完了条件

- [ ] 実装が完了している
- [ ] 自動テストが成功している
- [ ] 手動テストが成功している
- [ ] 手動テスト結果を記録している
- [ ] 未確認事項が残っていない
