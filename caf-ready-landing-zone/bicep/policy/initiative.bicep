targetScope = 'managementGroup'

// ============================================================
// Azure Policy Initiative の定義と割当
// caf-ready-landing-zone/bicep/policy/initiative.bicep
// ============================================================

@description('組織の接頭辞')
@minLength(2)
@maxLength(8)
param orgPrefix string

@description('環境名')
@allowed(['dev', 'staging', 'prod'])
param environmentName string

@description('ポリシーを割り当てる管理グループ ID（通常は組織ルート）')
param managementGroupRootId string

// ============================================================
// CAF 基盤 Policy Initiative の定義
// ============================================================
resource cafBaselineInitiative 'Microsoft.Authorization/policySetDefinitions@2023-04-01' = {
  name: '${orgPrefix}-caf-baseline-initiative'
  properties: {
    displayName: '[${orgPrefix}] CAF Baseline Initiative'
    description: 'Azure Cloud Adoption Framework のベースラインセキュリティ・ガバナンスポリシーセット'
    policyType: 'Custom'
    metadata: {
      category: 'CAF'
      version: '1.0.0'
    }
    parameters: {
      logAnalyticsWorkspaceId: {
        type: 'String'
        metadata: {
          displayName: 'Log Analytics Workspace ID'
          description: '診断ログの送付先 Log Analytics Workspace のリソース ID'
        }
      }
      allowedLocations: {
        type: 'Array'
        metadata: {
          displayName: '許可リージョン一覧'
          description: 'リソースをデプロイできるリージョンの一覧'
          strongType: 'location'
        }
        defaultValue: [
          'japaneast'
          'japanwest'
        ]
      }
    }
    policyDefinitions: [
      // ① 許可リージョンの強制
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c'
        policyDefinitionReferenceId: 'allowed-locations'
        parameters: {
          listOfAllowedLocations: {
            value: '[parameters(\'allowedLocations\')]'
          }
        }
      }
      // ② 診断設定の強制（サブスクリプションアクティビティログ）
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/2465583e-4e78-4c15-b6be-a36cbc7c8b0f'
        policyDefinitionReferenceId: 'activity-log-to-law'
        parameters: {
          logAnalytics: {
            value: '[parameters(\'logAnalyticsWorkspaceId\')]'
          }
        }
      }
      // ③ Microsoft Defender for Cloud の有効化（サブスクリプション）
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/ac076320-ddcf-4066-b451-6153267e8aed'
        policyDefinitionReferenceId: 'mdc-enable'
        parameters: {}
      }
      // ④ HTTPS のみ許可（Storage Account）
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9'
        policyDefinitionReferenceId: 'storage-https-only'
        parameters: {}
      }
      // ⑤ TLS 1.2 以上の強制（Storage Account）
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/fe83a0eb-a853-422d-aac2-1bffd182c5d0'
        policyDefinitionReferenceId: 'storage-tls12'
        parameters: {}
      }
      // ⑥ Key Vault の論理削除を有効化
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/0b60c0b2-2dc2-4e1c-b5c9-abbed971de53'
        policyDefinitionReferenceId: 'kv-soft-delete'
        parameters: {}
      }
    ]
  }
}

// ============================================================
// Initiative の割当（組織ルート管理グループに適用）
// ============================================================
resource cafBaselineAssignment 'Microsoft.Authorization/policyAssignments@2023-04-01' = {
  name: '${orgPrefix}-caf-baseline-assignment'
  properties: {
    displayName: '[${orgPrefix}] CAF Baseline Assignment'
    description: 'CAF Baseline Initiative を組織全体に適用'
    policyDefinitionId: cafBaselineInitiative.id
    enforcementMode: environmentName == 'prod' ? 'Default' : 'DoNotEnforce'
    parameters: {
      logAnalyticsWorkspaceId: {
        // TODO: Management サブスクリプション構築後、LAW のリソース ID を設定してください
        // 例: /subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<law-name>
        value: ''
      }
      allowedLocations: {
        value: [
          'japaneast'
          'japanwest'
        ]
      }
    }
    identity: {
      type: 'SystemAssigned'
    }
  }
}

// ============================================================
// 出力値
// ============================================================
@description('Initiative 定義 ID')
output initiativeId string = cafBaselineInitiative.id

@description('Policy 割当 ID')
output assignmentId string = cafBaselineAssignment.id

@description('Policy 割当に使用するマネージド ID のプリンシパル ID')
output assignmentPrincipalId string = cafBaselineAssignment.identity.principalId
