# Cloud Platform スキル

このスキルファイルは `@cloud-platform` エージェントが提供する再利用可能な知識・手順を定義します。

---

## スキル 1: Azure Landing Zone 管理グループ階層

```
テナントルートグループ
└── 組織ルート
    ├── Platform（プラットフォーム）
    │   ├── Management（管理）
    │   ├── Connectivity（接続）
    │   └── Identity（ID）
    ├── Landing Zones（ランディングゾーン）
    │   ├── Corp（企業内部）
    │   └── Online（インターネット公開）
    ├── Sandbox（サンドボックス）
    └── Decommissioned（廃止）
```

| 管理グループ | 目的 | 主なリソース |
|---|---|---|
| **Management** | 集中管理・監視 | Log Analytics、Automation、Sentinel |
| **Connectivity** | ネットワーク集約 | Hub VNet、Azure Firewall、ExpressRoute/VPN |
| **Identity** | ID 基盤 | AD DC、Entra Connect |
| **Corp** | 社内ワークロード | プライベート接続が必要なアプリ |
| **Online** | 公開ワークロード | インターネット公開アプリ |
| **Sandbox** | 実験・検証 | PoC、学習用（本番接続なし） |

---

## スキル 2: Hub-Spoke ネットワークトポロジ

```
                ┌──────────────┐
                │  ExpressRoute │
                │  / VPN GW     │
                └──────┬───────┘
                       │
                ┌──────┴───────┐
On-premises ────┤   Hub VNet    │
                │ Azure FW/NVA  │
                │ Bastion       │
                │ DNS Private   │
                └──┬───┬───┬───┘
          ┌────────┘   │   └────────┐
   ┌──────┴──────┐ ┌──┴──────┐ ┌───┴──────┐
   │ Spoke VNet  │ │ Spoke   │ │ Spoke    │
   │ (Workload1) │ │ (WL2)   │ │ (WL3)    │
   └─────────────┘ └─────────┘ └──────────┘
```

---

## スキル 3: Bicep ファイル構成標準

```
infra/
├── main.bicep                  # エントリポイント
├── bicepconfig.json            # Bicep 設定・リンター構成
├── parameters/
│   ├── dev.bicepparam
│   ├── staging.bicepparam
│   └── prod.bicepparam
└── modules/
    ├── networking/
    │   ├── vnet.bicep
    │   ├── nsg.bicep
    │   └── private-endpoint.bicep
    ├── identity/
    │   └── managed-identity.bicep
    ├── monitoring/
    │   ├── log-analytics.bicep
    │   └── diagnostic-settings.bicep
    └── security/
        ├── key-vault.bicep
        └── policy-assignment.bicep
```

### Bicep コーディングテンプレート

```bicep
@description('デプロイ先のリージョン')
param location string = resourceGroup().location

@description('環境名')
@allowed(['dev', 'staging', 'prod'])
param environmentName string

@description('ワークロード名（2〜10文字）')
@minLength(2)
@maxLength(10)
param workloadName string

var namingPrefix = '${workloadName}-${environmentName}'
var tags = {
  Environment: environmentName
  Workload: workloadName
  ManagedBy: 'Bicep'
}

module vnet 'modules/networking/vnet.bicep' = {
  name: 'deploy-vnet-${namingPrefix}'
  params: {
    location: location
    name: '${namingPrefix}-vnet'
    tags: tags
  }
}
```

---

## スキル 4: Terraform ファイル構成標準

```
infra/
├── main.tf                     # ルートモジュール
├── variables.tf                # 入力変数
├── outputs.tf                  # 出力値
├── locals.tf                   # 命名規則・共通タグ
├── backend.tf                  # リモートステート
├── versions.tf                 # プロバイダーバージョン
├── environments/
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
└── modules/
    ├── networking/
    ├── identity/
    ├── monitoring/
    └── security/
```

### Terraform コーディングテンプレート

```hcl
# versions.tf
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# locals.tf
locals {
  naming_prefix = "${var.workload_name}-${var.environment_name}"
  common_tags = {
    Environment = var.environment_name
    Workload    = var.workload_name
    ManagedBy   = "Terraform"
  }
}
```

---

## スキル 5: IaC 品質チェックリスト

| 観点 | チェック項目 | Bicep | Terraform |
|---|---|---|---|
| **冪等性** | 再実行しても同じ結果 | `what-if` で確認 | `plan` で確認 |
| **シークレット管理** | コードにハードコードなし | Key Vault `getSecret()` | Key Vault データソース |
| **パラメータ化** | 環境差分はパラメータで管理 | `.bicepparam` | `.tfvars` |
| **モジュール化** | 単一責任の原則 | `modules/` 配下 | `modules/` 配下 |
| **バージョニング** | セマンティックバージョニング | Bicep レジストリ | Terraform Registry |
| **テスト** | 変更プレビュー必須 | `what-if` | `plan` |

---

## スキル 6: セキュリティ要件の IaC 反映パターン

| セキュリティ要件 | IaC での実装方法 |
|---|---|
| HTTPS 通信強制 | `httpsOnly: true` をデフォルト値に |
| プライベートエンドポイント必須 | PaaS モジュールに Private Endpoint を組み込み |
| 診断ログ有効化 | 各モジュールに Diagnostic Settings を標準装備 |
| ネットワーク制限 | NSG・Firewall ルールをモジュール化 |
| 暗号化強制 | CMK 構成をモジュールに組み込み |
| マネージド ID 使用 | マネージド ID を既定値に設定 |

---

*参照エージェント: `@cloud-platform`*
*関連スキル: `.github/skills/cloud-governance/SKILL.md`, `.github/skills/cloud-security/SKILL.md`*
*関連インストラクション: `.github/instructions/bicep.instructions.md`, `.github/instructions/terraform.instructions.md`*
