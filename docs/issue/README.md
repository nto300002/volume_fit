# Issue 一覧

設計文書から抽出した初期 Issue とデプロイ関連 Issue を、1 Issue 1 Markdown で管理するためのディレクトリです。

各 Issue には、TDD、受け入れ要件、手動テスト、完了条件のチェックリストを含めます。Issue を GitHub へ起票する場合は、該当ファイルの内容をベースにします。

## 運用ルール

- 1 Issue は小さなユーザー価値または確認可能な振る舞いにする
- 実装前に失敗するテストを追加する
- 自動テストだけでなく手動テスト結果も記録する
- 手動テストが未実施なら Issue を完了にしない
- staging / production に関係する Issue はデプロイ確認も完了条件に含める

## Issue ファイル

| ファイル | Epic | Issue |
|---|---|---|
| [001-web-foundation.md](001-web-foundation.md) | Web 基盤 | Flutter Web プロジェクトを初期化する |
| [002-environment-separation.md](002-environment-separation.md) | Web 基盤 | dev/stg/prod 環境を分離する |
| [003-riverpod-foundation.md](003-riverpod-foundation.md) | Web 基盤 | Riverpod 基盤を構築する |
| [004-go-router-foundation.md](004-go-router-foundation.md) | Web 基盤 | go_router を構築する |
| [005-firebase-web-connection.md](005-firebase-web-connection.md) | Web 基盤 | Firebase Web 接続を構築する |
| [006-initial-security-rules.md](006-initial-security-rules.md) | Web 基盤 | Firestore Security Rules の初期構成を作成する |
| [007-email-register.md](007-email-register.md) | 認証 | メールアドレスで登録できる |
| [008-email-login.md](008-email-login.md) | 認証 | メールアドレスでログインできる |
| [009-google-login.md](009-google-login.md) | 認証 | Google でログインできる |
| [010-password-reset.md](010-password-reset.md) | 認証 | パスワードを再設定できる |
| [011-logout.md](011-logout.md) | 認証 | ログアウトできる |
| [012-save-initial-profile.md](012-save-initial-profile.md) | 最初の縦切り | 初回プロフィールを Firestore へ保存できる |
| [013-input-push-up-one-set.md](013-input-push-up-one-set.md) | 最初の縦切り | 腕立て伏せ 1 セットを入力できる |
| [014-calculate-bodyweight-load.md](014-calculate-bodyweight-load.md) | 最初の縦切り | 自重推定負荷を計算できる |
| [015-calculate-set-volume.md](015-calculate-set-volume.md) | 最初の縦切り | セットボリュームを計算できる |
| [016-calculate-rir-adjusted-volume.md](016-calculate-rir-adjusted-volume.md) | 最初の縦切り | RIR 補正値を計算できる |
| [017-judge-hard-set.md](017-judge-hard-set.md) | 最初の縦切り | ハードセットを判定できる |
| [018-save-push-up-one-set.md](018-save-push-up-one-set.md) | 最初の縦切り | 腕立て伏せ 1 セットを Firestore へ保存できる |
| [019-show-firestore-save-status.md](019-show-firestore-save-status.md) | 最初の縦切り | Firestore の保存状態を表示できる |
| [020-generate-ai-markdown.md](020-generate-ai-markdown.md) | 最初の縦切り | AI 用 Markdown を生成できる |
| [021-save-ai-export-history.md](021-save-ai-export-history.md) | 最初の縦切り | AI 出力履歴を Firestore へ保存できる |
| [022-record-multiple-sets.md](022-record-multiple-sets.md) | Web MVP 拡張 | 複数セットを記録できる |
| [023-duplicate-previous-set.md](023-duplicate-previous-set.md) | Web MVP 拡張 | 前セットを複製できる |
| [024-record-external-weight-exercise.md](024-record-external-weight-exercise.md) | Web MVP 拡張 | 外部重量種目を記録できる |
| [025-show-workout-history-list.md](025-show-workout-history-list.md) | Web MVP 拡張 | 履歴一覧を表示できる |
| [026-show-session-detail.md](026-show-session-detail.md) | Web MVP 拡張 | セッション詳細を表示できる |
| [027-compare-past-records.md](027-compare-past-records.md) | Web MVP 拡張 | 過去記録と比較できる |
| [028-create-next-plan.md](028-create-next-plan.md) | Web MVP 拡張 | 次回予定を登録できる |
| [029-custom-calculation-settings.md](029-custom-calculation-settings.md) | Web MVP 拡張 | カスタム計算設定を作成できる |
| [030-json-export.md](030-json-export.md) | Web MVP 拡張 | JSON エクスポートできる |
| [031-json-import.md](031-json-import.md) | Web MVP 拡張 | JSON インポートできる |
| [032-delete-account.md](032-delete-account.md) | Web MVP 拡張 | アカウントを削除できる |
| [033-pwa-installable.md](033-pwa-installable.md) | PWA | PWA としてインストールできる |
| [034-show-offline-pending-writes.md](034-show-offline-pending-writes.md) | PWA | オフライン時の保留書き込みを表示できる |
| [035-sync-after-connectivity-restored.md](035-sync-after-connectivity-restored.md) | PWA | 通信復旧後に書き込みを反映できる |
| [036-safe-reload-after-update.md](036-safe-reload-after-update.md) | PWA | 更新通知後に安全に再読み込みできる |
| [037-android-home-screen.md](037-android-home-screen.md) | Android | Android 用ホーム画面を実装する |
| [038-android-set-input-screen.md](038-android-set-input-screen.md) | Android | Android 用セット入力画面を実装する |
| [039-android-os-share-sheet.md](039-android-os-share-sheet.md) | Android | OS 共有シートを利用できる |
| [040-protect-input-on-background.md](040-protect-input-on-background.md) | Android | バックグラウンド移行時に入力を保護する |
| [041-android-internal-test.md](041-android-internal-test.md) | Android | Android 内部テストを完了する |
| [042-deploy-dev-firebase-project.md](042-deploy-dev-firebase-project.md) | 環境・本番基盤 | development Firebase プロジェクトを構築する |
| [043-deploy-staging-firebase-project.md](043-deploy-staging-firebase-project.md) | 環境・本番基盤 | staging Firebase プロジェクトを構築する |
| [044-deploy-production-firebase-project.md](044-deploy-production-firebase-project.md) | 環境・本番基盤 | production Firebase プロジェクトを早期構築する |
| [045-generate-flutterfire-per-environment.md](045-generate-flutterfire-per-environment.md) | 環境・本番基盤 | 環境別 FlutterFire 設定を生成する |
| [046-configure-hosting-three-envs.md](046-configure-hosting-three-envs.md) | 環境・本番基盤 | Firebase Hosting を 3 環境へ設定する |
| [047-create-firestore-indexes-file.md](047-create-firestore-indexes-file.md) | 環境・本番基盤 | Firestore Indexes 管理ファイルを作成する |
| [048-deploy-production-maintenance-page.md](048-deploy-production-maintenance-page.md) | 環境・本番基盤 | production へメンテナンスページを初回配備する |
| [049-ci-run-tests-on-pr.md](049-ci-run-tests-on-pr.md) | CI/CD・配備 | Pull Request で自動テストを実行する |
| [050-deploy-staging-preview-channel.md](050-deploy-staging-preview-channel.md) | CI/CD・配備 | staging Preview Channel へ配備できる |
| [051-deploy-production-preview-channel.md](051-deploy-production-preview-channel.md) | CI/CD・配備 | production Preview Channel へ手動配備できる |
| [052-manual-approval-production-live.md](052-manual-approval-production-live.md) | CI/CD・配備 | production live 配備を手動承認制にする |
| [053-production-release-checklist.md](053-production-release-checklist.md) | CI/CD・配備 | production 配備前チェックリストを作成する |
| [054-web-rollback-procedure.md](054-web-rollback-procedure.md) | CI/CD・配備 | Web のロールバック手順を確認する |
