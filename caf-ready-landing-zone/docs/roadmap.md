# ロードマップ

このドキュメントは `caf-ready-landing-zone` の **今後の実装予定・検討中の機能** を整理します。
現在のスコープ（MVP）に含まれない項目を記録し、優先度とともに管理します。

---

## 現在の MVP スコープ（v1.0）

| 機能 | 実装状況 | 担当 |
|---|---|---|
| 管理グループ階層の作成 | ✅ 完了 | Platform Team |
| Hub-Spoke ネットワーク（AVM） | ✅ 完了 | Platform Team |
| サブスクリプション自動発行（AVM） | ✅ 完了 | Platform Team |
| CAF Baseline Policy Initiative | ✅ 完了 | Governance Team |
| CI/CD（Bicep Validate + Deploy） | ✅ 完了 | Platform Team |
| ADR 初期 3 件 | ✅ 完了 | Platform Team |

---

## 次フェーズ（v1.1 〜 v1.x）

### 🔴 High Priority

| 機能 | 概要 | 関連 Issue |
|---|---|---|
| **Management サブスクリプション構築** | Log Analytics Workspace、Microsoft Sentinel、Defender for Cloud の自動構成 | TBD |
| **Identity サブスクリプション構築** | Entra Connect、ADDS の IaC 化 | TBD |
| **Policy コンプライアンスダッシュボード** | Azure Policy の適合状況を GitHub Actions で定期レポート | TBD |
| **Cost Management アラート** | 予算超過アラートの自動設定 | TBD |

### 🟡 Medium Priority

| 機能 | 概要 | 関連 Issue |
|---|---|---|
| **Spoke VNet ワークロードテンプレート** | Corp/Online 用の汎用 Spoke VNet テンプレート | TBD |
| **Private DNS Resolver** | オンプレミスからのプライベート DNS 解決 | TBD |
| **GitOps による Policy 管理** | `definitions/` の Policy を自動同期 | TBD |
| **Bicep テスト（PSRule）** | Bicep ファイルの静的解析・テスト自動化 | TBD |

### 🟢 Low Priority / 将来検討

| 機能 | 概要 | 検討条件 |
|---|---|---|
| **Virtual WAN 移行** | グローバル展開（3 リージョン以上）時に検討 | ADR-0002 参照 |
| **Terraform バリアント** | マルチクラウド要件発生時 | ADR-0001 参照 |
| **Azure DevOps パイプライン** | GitHub Actions に加えて ADO をサポート | 顧客要件次第 |
| **FinOps ダッシュボード** | Azure Cost Management + Power BI の自動デプロイ | 中規模以上の組織 |
| **複数テナント対応** | マルチテナントでの Landing Zone 展開 | エンタープライズ要件次第 |

---

## スコープ外（永続的）

以下の項目は本リポジトリのスコープ外として位置づけます。
別リポジトリまたは別プロジェクトで管理してください。

| 項目 | 理由 | 代替 |
|---|---|---|
| アプリケーションワークロードの IaC | ワークロード固有の設定はワークロードチームが管理 | 各アプリのリポジトリ |
| データプラットフォーム構築 | Landing Zone の上位レイヤー | 専用データプラットフォームリポジトリ |
| CI/CD プラットフォーム（GitHub Enterprise 設定等） | 組織管理レベルの設定 | IT 管理チーム |
| コスト配賦・チャージバックシステム | 財務システムとの連携が必要 | FinOps チーム |

---

## 貢献方法

ロードマップへの追加・変更提案は GitHub Issue でお知らせください。
優先度の変更は Platform Team との合意が必要です（`docs/decisions/` に ADR を作成して議論してください）。

---

*最終更新: 2026-05-11 | 担当: Platform Team (@NakayamaKento)*
