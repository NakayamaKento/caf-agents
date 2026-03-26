---
name: cloud-governance
description: クラウドガバナンス スキル — ガバナンス 5 分野チェックリスト、推奨 Azure Policy 一覧、RBAC カスタムロールテンプレート、KQL コンプライアンスクエリ集を提供します。
---

# Cloud Governance スキル

このスキルファイルは `@cloud-governance` エージェントが提供する再利用可能な知識・手順を定義します。

---

## スキル 1: ガバナンス 5 分野チェックリスト

Azure CAF ガバナンス 5 分野の実装状況を評価します。

| 分野 | 主要ポリシー | 実装状態 |
|---|---|---|
| **コスト管理** | Allowed resource types、VM SKU 制限、タグ強制 | `[ ]` Audit `[ ]` Deny |
| **セキュリティベースライン** | MCSB イニシアティブ、HTTPS 強制、診断ログ | `[ ]` Audit `[ ]` Deny |
| **リソース整合性** | 許可リージョン、タグ強制、リソースロック | `[ ]` Audit `[ ]` Deny |
| **ID ベースライン** | MFA 強制、外部アカウント制限、PIM | `[ ]` Audit `[ ]` Deny |
| **デプロイ高速化** | Policy as Code、IaC 必須化 | `[ ]` Audit `[ ]` Deny |

---

## スキル 2: ガバナンス成熟度モデル

| レベル | 特徴 | 推奨アクション |
|---|---|---|
| **1: 初期** | アドホックなポリシー、個人依存 | 基本 Audit ポリシー、タグ戦略策定 |
| **2: 管理** | 基本ポリシー定義済み、部分適用 | Deny 移行、RBAC 整備 |
| **3: 定義** | 体系的ポリシーが Deny モード適用 | Policy as Code、自動コンプライアンス監視 |
| **4: 測定** | 自動化されたコンプライアンス管理 | KPI ダッシュボード、コスト最適化自動化 |
| **5: 最適化** | AI 支援によるポリシー最適化 | 継続的改善、業界ベンチマーク対比 |

---

## スキル 3: 推奨 Azure Policy 一覧

### コスト管理

| ポリシー名 | 効果 | 目的 |
|---|---|---|
| `Allowed resource types` | Deny | 高コストリソース作成防止 |
| `Allowed virtual machine size SKUs` | Deny | VM 過剰スペック抑止 |
| `Require a tag and its value on resources` | Deny | コストセンタータグ強制 |
| `Inherit a tag from the resource group` | Modify | タグ自動継承 |

### セキュリティベースライン

| ポリシー名 | 効果 | 目的 |
|---|---|---|
| `Microsoft cloud security benchmark` | Audit/AuditIfNotExists | MCSB 包括適用 |
| `Secure transfer to storage accounts should be enabled` | Audit | HTTPS 強制 |
| `Network interfaces should not have public IPs` | Audit | パブリック IP 制限 |
| `Key Vault should use a virtual network service endpoint` | Audit | Key Vault ネットワーク制限 |
| `SQL servers should have auditing enabled` | AuditIfNotExists | SQL 監査強制 |

### リソース整合性

| ポリシー名 | 効果 | 目的 |
|---|---|---|
| `Allowed locations` | Deny | データ主権対応 |
| `Azure Backup should be enabled for Virtual Machines` | AuditIfNotExists | VM バックアップ強制 |

### ID ベースライン

| ポリシー名 | 効果 | 目的 |
|---|---|---|
| `MFA should be enabled for accounts with owner permissions` | Audit | 特権アカウント MFA |
| `A maximum of 3 owners should be designated for your subscription` | Audit | オーナー数制限 |
| `External accounts with owner permissions should be removed` | Audit | 外部アカウント制限 |

---

## スキル 4: RBAC 標準ロール割り当てテンプレート

| スコープ | ロール | 対象 | 目的 |
|---|---|---|---|
| 管理グループ (ルート) | Owner | クラウドガバナンスチーム | ポリシー割り当て・管理 |
| 管理グループ (ルート) | Reader | 監査チーム | コンプライアンス監査 |
| サブスクリプション | Contributor | ワークロードチーム | リソース管理 |
| サブスクリプション | Cost Management Reader | FinOps チーム | コスト監視 |
| リソースグループ | カスタムロール | 開発チーム | 最小権限アクセス |

---

## スキル 5: KQL コンプライアンス監視クエリ集

### ポリシー非準拠リソースの一覧

```kusto
PolicyStates
| where TimeGenerated > ago(7d)
| where ComplianceState == "NonCompliant"
| summarize
    nonCompliantCount = dcount(ResourceId),
    latestTimestamp = max(TimeGenerated)
    by PolicyDefinitionName, PolicyDefinitionAction, SubscriptionId
| order by nonCompliantCount desc
```

### RBAC 変更の監査（特権ロール割り当て）

```kusto
AzureActivity
| where OperationNameValue == "MICROSOFT.AUTHORIZATION/ROLEASSIGNMENTS/WRITE"
| where ActivityStatusValue == "Success"
| extend
    principalId = tostring(parse_json(Properties).requestbody.properties.principalId),
    roleDefinitionId = tostring(parse_json(Properties).requestbody.properties.roleDefinitionId)
| project TimeGenerated, Caller, principalId, roleDefinitionId, ResourceGroup
| order by TimeGenerated desc
```

### コスト超過アラートの検出

```kusto
AzureActivity
| where CategoryValue == "Budget"
| where OperationNameValue contains "Alert"
| project TimeGenerated, Caller, ResourceGroup, Properties
| extend budgetName = tostring(Properties.budgetName)
| where isnotempty(budgetName)
| order by TimeGenerated desc
```

---

## スキル 6: Policy as Code ワークフロー

```
ポリシー定義（JSON / Bicep / Terraform）
    │
    ├── Git リポジトリで管理（ブランチ保護 + PR レビュー必須）
    │
    ├── CI: Audit モードで非準拠リソースを検出・報告
    │
    ├── レビュー・承認（ガバナンスチーム + 影響チーム）
    │
    └── CD: 管理グループ階層に適用
            Audit → AuditIfNotExists → Deny（段階的移行）
```

---

*参照エージェント: `@cloud-governance`*
*関連スキル: `.github/skills/cloud-platform/SKILL.md`, `.github/skills/cloud-security/SKILL.md`*
*関連インストラクション: `.github/instructions/bicep.instructions.md`, `.github/instructions/terraform.instructions.md`, `.github/instructions/policy.instructions.md`*
