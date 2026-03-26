---
applyTo: "**/*.bicep,**/*.bicepparam,**/bicepconfig.json"
---

# Bicep コーディングガイドライン

このインストラクションは `.bicep`、`.bicepparam`、`bicepconfig.json` ファイルに自動適用されます。

---

## 1. ファイル構成標準

```
infra/
├── main.bicep                  # エントリポイント（1 ファイル）
├── bicepconfig.json            # リンター・実験的機能の設定
├── parameters/
│   ├── dev.bicepparam          # 開発環境パラメータ
│   ├── staging.bicepparam      # ステージング環境パラメータ
│   └── prod.bicepparam         # 本番環境パラメータ
└── modules/
    ├── networking/             # ネットワーク関連モジュール
    ├── identity/               # ID・マネージド ID
    ├── monitoring/             # 監視・診断設定
    └── security/               # Key Vault・ポリシー割り当て
```

---

## 2. 必須のコーディング規則

### パラメータ宣言

```bicep
// ✅ 推奨: デコレータで完全に文書化
@description('デプロイ先のリージョン')
param location string = resourceGroup().location

@description('環境名')
@allowed(['dev', 'staging', 'prod'])
param environmentName string

@description('ワークロード名（英数字、2〜10文字）')
@minLength(2)
@maxLength(10)
param workloadName string

// ❌ 非推奨: 説明なし、バリデーションなし
param env string
```

### 命名規則

```bicep
// ✅ 推奨: 命名を一元管理
var namingPrefix = '${workloadName}-${environmentName}'
var tags = {
  Environment: environmentName
  Workload: workloadName
  ManagedBy: 'Bicep'
  Owner: 'platform-team'
  CostCenter: costCenterCode
}
```

### モジュール参照

```bicep
// ✅ 推奨: モジュール化で再利用性を確保
module vnet 'modules/networking/vnet.bicep' = {
  name: 'deploy-vnet-${namingPrefix}'
  params: {
    location: location
    name: '${namingPrefix}-vnet'
    addressPrefixes: ['10.0.0.0/16']
    tags: tags
  }
}
```

---

## 3. セキュリティ必須事項

### シークレット管理

```bicep
// ✅ 推奨: Key Vault 参照
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: '${namingPrefix}-sql'
  properties: {
    administratorLogin: 'sqladmin'
    administratorLoginPassword: keyVault.getSecret('sql-admin-password')
  }
}

// ❌ 禁止: ハードコードされたシークレット
resource sqlServerBad 'Microsoft.Sql/servers@2023-05-01-preview' = {
  properties: {
    administratorLoginPassword: 'P@ssw0rd123!'  // 絶対にしない
  }
}
```

### マネージド ID

```bicep
// ✅ 推奨: ユーザー割り当てマネージド ID
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${namingPrefix}-identity'
  location: location
  tags: tags
}

resource appService 'Microsoft.Web/sites@2023-12-01' = {
  properties: {
    // マネージド ID を使用（サービスプリンシパルは使わない）
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
}
```

### 診断設定（すべてのリソースに必須）

```bicep
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-${resource.name}'
  scope: resource
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 90
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}
```

---

## 4. bicepconfig.json 推奨設定

```json
{
  "analyzers": {
    "core": {
      "enabled": true,
      "verbose": false,
      "rules": {
        "no-hardcoded-env-urls": { "level": "error" },
        "no-unnecessary-dependson": { "level": "warning" },
        "no-unused-params": { "level": "warning" },
        "no-unused-vars": { "level": "warning" },
        "prefer-interpolation": { "level": "warning" },
        "secure-parameter-default": { "level": "error" },
        "simplify-interpolation": { "level": "warning" },
        "use-recent-api-versions": { "level": "warning" },
        "use-stable-vm-image": { "level": "warning" }
      }
    }
  }
}
```

---

## 5. CI/CD 統合パターン

```yaml
# GitHub Actions での Bicep デプロイ
- name: Bicep What-If
  run: |
    az deployment group what-if \
      --resource-group ${{ vars.RESOURCE_GROUP }} \
      --template-file infra/main.bicep \
      --parameters @infra/parameters/${{ vars.ENVIRONMENT }}.bicepparam

- name: Bicep Deploy
  if: github.ref == 'refs/heads/main'
  run: |
    az deployment group create \
      --resource-group ${{ vars.RESOURCE_GROUP }} \
      --template-file infra/main.bicep \
      --parameters @infra/parameters/${{ vars.ENVIRONMENT }}.bicepparam
```

---

## 6. チェックリスト

デプロイ前に以下を確認してください:

- [ ] すべてのパラメータに `@description` デコレータがある
- [ ] シークレットは Key Vault 参照または `@secure()` デコレータを使用
- [ ] 命名規則が `.github/copilot-instructions.md` の規則に準拠
- [ ] 必須タグ（Environment, Workload, CostCenter, Owner, ManagedBy）が設定されている
- [ ] 診断設定が各リソースに設定されている
- [ ] `what-if` でデプロイ変更内容を確認済み
- [ ] `bicepconfig.json` のリンタールールがエラーなし
