# caf-ready-landing-zone

Azure Cloud Adoption Framework (CAF) に準拠した **Ready** フェーズの Landing Zone IaC リポジトリです。
Bicep と Azure Verified Modules (AVM) を組み合わせて、企業グレードのクラウド基盤を提供します。

## 概要

| 項目 | 内容 |
|---|---|
| **スコープ** | サブスクリプション / 管理グループ |
| **IaC ツール** | Azure Bicep |
| **モジュール** | Azure Verified Modules (AVM) Pattern Modules |
| **デプロイ方式** | GitHub Actions + OIDC (フェデレーション資格情報) |
| **ガバナンス** | Azure Policy Initiative + Management Groups |

## ディレクトリ構造

```
caf-ready-landing-zone/
├── .github/
│   ├── workflows/
│   │   ├── bicep-validate.yml      # az bicep build + what-if
│   │   └── bicep-deploy.yml        # OIDC で Azure へデプロイ
│   └── CODEOWNERS
├── bicep/
│   ├── main.bicep                  # サブスクリプションスコープのエントリポイント
│   ├── modules/
│   │   ├── management-groups.bicep # MG 階層の作成（自前最小実装）
│   │   └── naming.bicep            # 命名規則（接頭辞・略号）
│   ├── lz/                         # AVM Pattern Modules を呼び出すラッパー
│   │   ├── sub-vending.bicep       # avm/ptn/lz/sub-vending 利用
│   │   └── hub-networking.bicep    # avm/ptn/network/hub-networking 利用
│   └── policy/
│       ├── initiative.bicep        # 初期 Initiative の定義と割当
│       └── definitions/            # 自前 Policy 定義（最小限）
├── docs/
│   ├── decisions/                  # ADR 形式の意思決定記録
│   └── roadmap.md                  # フォーカス外項目のロードマップ
└── README.md
```

## 前提条件

| 要件 | 詳細 |
|---|---|
| Azure サブスクリプション | 管理グループ作成権限（`Management Group Contributor`）が必要 |
| Entra ID テナント | フェデレーション資格情報の登録が必要 |
| GitHub Environments | `production` 環境（Required reviewers 推奨） |
| Azure CLI | `az bicep` サブコマンドが使える環境 |

## クイックスタート

### 1. フェデレーション資格情報の設定

```bash
# サービスプリンシパルの作成（または既存を使用）
az ad app create --display-name "caf-lz-deploy"

# フェデレーション資格情報を追加
az ad app federated-credential create \
  --id <APP_ID> \
  --parameters '{
    "name": "github-deploy",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:NakayamaKento/caf-ready-landing-zone:environment:production",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

### 2. GitHub シークレット / 変数の設定

| 名前 | 種別 | 説明 |
|---|---|---|
| `AZURE_TENANT_ID` | Secret | Entra ID テナント ID |
| `AZURE_CLIENT_ID` | Secret | アプリケーション（クライアント）ID |
| `AZURE_SUBSCRIPTION_ID` | Secret | デプロイ先サブスクリプション ID |
| `MANAGEMENT_GROUP_ROOT_ID` | Variable | ルート管理グループ ID |

### 3. Bicep デプロイ

```bash
# ローカルでの What-If 確認
az deployment sub what-if \
  --location japaneast \
  --template-file bicep/main.bicep \
  --parameters environmentName=dev \
               orgPrefix=contoso

# デプロイ
az deployment sub create \
  --location japaneast \
  --template-file bicep/main.bicep \
  --parameters environmentName=prod \
               orgPrefix=contoso
```

## CI/CD フロー

```
Pull Request
  └── bicep-validate.yml
        ├── az bicep build（構文チェック）
        └── az deployment sub what-if（変更プレビュー）

Merge to main
  └── bicep-deploy.yml
        ├── OIDC 認証（az login --federated-token）
        └── az deployment sub create（実際のデプロイ）
```

## アーキテクチャ

### 管理グループ階層

```
テナントルートグループ
└── {orgPrefix}-root
    ├── {orgPrefix}-platform
    │   ├── {orgPrefix}-management
    │   ├── {orgPrefix}-connectivity
    │   └── {orgPrefix}-identity
    ├── {orgPrefix}-landingzones
    │   ├── {orgPrefix}-corp
    │   └── {orgPrefix}-online
    ├── {orgPrefix}-sandbox
    └── {orgPrefix}-decommissioned
```

### ネットワークトポロジ（Hub-Spoke）

```
On-premises
    │
    ▼
Hub VNet（Connectivity サブスクリプション）
    ├── Azure Firewall
    ├── VPN / ExpressRoute Gateway
    ├── Azure Bastion
    └── Private DNS Zones
         │
    ┌────┴────┐
    ▼         ▼
Spoke VNet  Spoke VNet
(Corp LZ)  (Online LZ)
```

## 関連ドキュメント

- [Azure Landing Zone 公式ドキュメント](https://learn.microsoft.com/ja-jp/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure Verified Modules](https://aka.ms/avm)
- [avm/ptn/lz/sub-vending](https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/lz/sub-vending)
- [avm/ptn/network/hub-networking](https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/network/hub-networking)
- [docs/decisions/](./docs/decisions/) — 意思決定記録（ADR）
- [docs/roadmap.md](./docs/roadmap.md) — 今後のロードマップ

## 命名規則

`.github/copilot-instructions.md` の規則に準拠します。

| リソース種別 | パターン | 例 |
|---|---|---|
| リソースグループ | `rg-{workload}-{env}-{region}` | `rg-connectivity-prod-jpe` |
| 仮想ネットワーク | `vnet-{workload}-{env}-{region}` | `vnet-hub-prod-jpe` |
| Key Vault | `kv-{workload}-{env}-{suffix}` | `kv-platform-prod-001` |

## コントリビューション

1. Issue またはADR（`docs/decisions/`）で変更内容を議論する
2. Feature ブランチを切って変更を実装する
3. Pull Request を作成し、`bicep-validate` が通ることを確認する
4. CODEOWNERS のレビューを受けてマージする

## ライセンス

MIT License — 詳細は [LICENSE](./LICENSE) を参照してください。
