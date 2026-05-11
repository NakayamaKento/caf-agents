# Policy 定義ディレクトリ

このディレクトリには **自前（カスタム）の Azure Policy 定義** を配置します。

## ファイル命名規則

```
definitions/
├── deny-public-ip.bicep          # パブリック IP の作成を拒否
├── audit-no-tags.bicep           # 必須タグなしリソースの監査
├── require-diagnostic-settings.bicep  # 診断設定の強制
└── ...
```

## Bicep テンプレート

```bicep
targetScope = 'managementGroup'

// Policy 定義のテンプレート
resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2023-04-01' = {
  name: 'custom-{policy-name}'
  properties: {
    displayName: '[Custom] {表示名}'
    description: 'ポリシーの説明'
    policyType: 'Custom'
    mode: 'All'         // または 'Indexed'（タグ・場所のみ対象）
    metadata: {
      category: 'Custom'
      version: '1.0.0'
    }
    parameters: {}
    policyRule: {
      if: {
        // 条件
      }
      then: {
        effect: 'Deny'  // Deny | Audit | DeployIfNotExists | Modify | AuditIfNotExists
      }
    }
  }
}
```

## 参考資料

- [Azure Policy 定義の構造](https://learn.microsoft.com/ja-jp/azure/governance/policy/concepts/definition-structure)
- [組み込みポリシー一覧](https://learn.microsoft.com/ja-jp/azure/governance/policy/samples/built-in-policies)
