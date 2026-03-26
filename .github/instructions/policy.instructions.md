---
applyTo: "**/policy/**/*.json,**/policies/**/*.json,**/*policy*.json,**/*initiative*.json"
---

# Azure Policy JSON コーディングガイドライン

このインストラクションは Azure Policy 定義・イニシアティブ定義の JSON ファイルに自動適用されます。

---

## 1. ポリシー定義 JSON の標準構造

```json
{
  "name": "{ポリシー一意識別子（kebab-case）}",
  "type": "Microsoft.Authorization/policyDefinitions",
  "properties": {
    "displayName": "{表示名（わかりやすい日本語または英語）}",
    "description": "{このポリシーの目的と効果を説明する文章}",
    "mode": "All",
    "metadata": {
      "version": "1.0.0",
      "category": "{カテゴリ（Security, Cost Management, Tagging など）}",
      "owner": "{担当チーム}",
      "createdOn": "{YYYY-MM-DD}"
    },
    "parameters": {
      "effect": {
        "type": "String",
        "defaultValue": "Audit",
        "allowedValues": ["Audit", "Deny", "Disabled"],
        "metadata": {
          "displayName": "効果",
          "description": "ポリシーの効果を指定します。Audit: 記録のみ、Deny: 拒否"
        }
      }
    },
    "policyRule": {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "{リソースタイプ}"
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]"
      }
    }
  }
}
```

---

## 2. ポリシーモード（mode）の選択

| mode | 用途 | 対象 |
|---|---|---|
| `All` | すべてのリソースタイプを対象 | 一般的なポリシー（推奨） |
| `Indexed` | タグ・場所をサポートするリソースのみ | タグ・リージョン制限ポリシー |
| `Microsoft.ContainerService.Data` | AKS クラスターポリシー | Kubernetes ポリシー |
| `Microsoft.Kubernetes.Data` | Arc 対応 Kubernetes | Arc Kubernetes ポリシー |

---

## 3. 効果（effect）の段階的適用

```
開発・評価フェーズ:  Audit（記録のみ、既存リソースに影響なし）
    ↓
準備フェーズ:       AuditIfNotExists（存在しない場合に監査）
    ↓
本番適用:           Deny（非準拠リソースの作成・更新を拒否）
```

### タグ強制の例（Audit → Modify → Deny の段階）

```json
{
  "properties": {
    "policyRule": {
      "if": {
        "allOf": [
          {
            "field": "type",
            "notIn": [
              "Microsoft.Resources/subscriptions/resourceGroups"
            ]
          },
          {
            "field": "tags['CostCenter']",
            "exists": "false"
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]"
      }
    }
  }
}
```

---

## 4. イニシアティブ定義（ポリシーセット）の構造

```json
{
  "name": "{イニシアティブ識別子}",
  "type": "Microsoft.Authorization/policySetDefinitions",
  "properties": {
    "displayName": "{イニシアティブ表示名}",
    "description": "{このイニシアティブの目的}",
    "metadata": {
      "version": "1.0.0",
      "category": "{カテゴリ}"
    },
    "parameters": {
      "effect": {
        "type": "String",
        "defaultValue": "Audit",
        "allowedValues": ["Audit", "Deny", "Disabled"]
      }
    },
    "policyDefinitions": [
      {
        "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/{built-in-id}",
        "policyDefinitionReferenceId": "{一意な参照ID}",
        "parameters": {
          "effect": {
            "value": "[parameters('effect')]"
          }
        }
      },
      {
        "policyDefinitionId": "/subscriptions/{sub-id}/providers/Microsoft.Authorization/policyDefinitions/{custom-policy-id}",
        "policyDefinitionReferenceId": "{一意な参照ID}",
        "parameters": {}
      }
    ]
  }
}
```

---

## 5. よく使うポリシールール条件パターン

### リソースタイプのフィルタリング

```json
{
  "field": "type",
  "equals": "Microsoft.Compute/virtualMachines"
}
```

### タグの存在確認

```json
{
  "field": "tags['Environment']",
  "exists": "false"
}
```

### リソースロケーションの制限

```json
{
  "field": "location",
  "notIn": "[parameters('allowedLocations')]"
}
```

### SKU サイズの制限

```json
{
  "field": "Microsoft.Compute/virtualMachines/sku.name",
  "notIn": "[parameters('allowedSKUs')]"
}
```

### プロパティ値の検証

```json
{
  "field": "Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly",
  "notEquals": "true"
}
```

---

## 6. ポリシー割り当て（Bicep）

```bicep
// policy-assignment.bicep
targetScope = 'managementGroup'

@description('ポリシーの効果')
@allowed(['Audit', 'Deny', 'Disabled'])
param effect string = 'Audit'

// 組み込みポリシーの割り当て例（MCSB イニシアティブ）
resource mcsbAssignment 'Microsoft.Authorization/policyAssignments@2024-04-01' = {
  name: 'mcsb-baseline'
  location: 'japaneast'
  identity: {
    type: 'SystemAssigned'  // DeployIfNotExists / Modify 効果に必要
  }
  properties: {
    displayName: 'Microsoft Cloud Security Benchmark'
    policyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8'
    enforcementMode: 'Default'
    parameters: {
      effect: { value: effect }
    }
  }
}
```

---

## 7. ポリシーテスト（Policy Compliance Scan）

```bash
# 既存リソースへのコンプライアンス評価をトリガー
az policy state trigger-scan \
  --resource-group "rg-workload-prod-jpe"

# 非準拠リソースの一覧取得
az policy state list \
  --filter "complianceState eq 'NonCompliant'" \
  --query "[].{resource:resourceId, policy:policyDefinitionName}" \
  --output table
```

---

## 8. チェックリスト

ポリシー定義のレビュー前に以下を確認:

- [ ] `name` がリポジトリ内でユニークで kebab-case に準拠
- [ ] `displayName` と `description` が明確で目的がわかる
- [ ] `metadata.category` が統一されたカテゴリに分類されている
- [ ] 効果（effect）がパラメータ化されており、`Disabled` オプションがある
- [ ] `mode` が目的に合っている（`All` または `Indexed`）
- [ ] まず `Audit` モードでテストし、問題がなければ `Deny` に移行する
- [ ] IaC（Bicep/Terraform）で割り当てが管理されている
- [ ] ポリシーの影響範囲（管理グループ/サブスクリプション/リソースグループ）が適切
