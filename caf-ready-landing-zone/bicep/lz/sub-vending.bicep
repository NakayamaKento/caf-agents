targetScope = 'subscription'

// ============================================================
// Sub Vending ラッパー
// Azure Verified Modules: avm/ptn/lz/sub-vending
// caf-ready-landing-zone/bicep/lz/sub-vending.bicep
// ============================================================
// AVM 参照: https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/lz/sub-vending

@description('デプロイ先のリージョン')
param location string

@description('環境名')
@allowed(['dev', 'staging', 'prod'])
param environmentName string

@description('組織の接頭辞')
@minLength(2)
@maxLength(8)
param orgPrefix string

@description('naming モジュールの出力オブジェクト')
param namingOutput object

@description('Corp 管理グループ ID')
param corpManagementGroupId string

@description('Online 管理グループ ID')
param onlineManagementGroupId string

@description('Enrollment Account の課金スコープ（例: /providers/Microsoft.Billing/billingAccounts/xxx/enrollmentAccounts/yyy）。空の場合は既存サブスクリプションへのアサインのみ実施')
param subscriptionBillingScope string = ''

// ============================================================
// AVM — avm/ptn/lz/sub-vending
// Connectivity サブスクリプションの自動発行
// ============================================================
// 注意: このモジュールはテナントレベルの権限（Enrollment Account）が必要です。
//       既存サブスクリプションを使用する場合は subscriptionId パラメータを指定してください。

module subVendingConnectivity 'br/public:avm/ptn/lz/sub-vending:0.5.3' = {
  name: 'sub-vending-connectivity'
  params: {
    subscriptionAliasEnabled: true
    subscriptionAliasName: '${orgPrefix}-connectivity-${environmentName}'
    subscriptionDisplayName: '${orgPrefix} - Connectivity (${environmentName})'
    subscriptionBillingScope: subscriptionBillingScope
    subscriptionWorkload: 'Production'
    subscriptionManagementGroupAssociationEnabled: true
    subscriptionManagementGroupId: '${orgPrefix}-connectivity'
    subscriptionTags: union(namingOutput.commonTags, {
      Workload: 'connectivity'
      CostCenter: 'CC-PLATFORM'
    })
    // ロールの割り当て（プラットフォームチームへの Network Contributor）
    roleAssignmentEnabled: false
    roleAssignments: []
  }
}

module subVendingManagement 'br/public:avm/ptn/lz/sub-vending:0.5.3' = {
  name: 'sub-vending-management'
  params: {
    subscriptionAliasEnabled: true
    subscriptionAliasName: '${orgPrefix}-management-${environmentName}'
    subscriptionDisplayName: '${orgPrefix} - Management (${environmentName})'
    subscriptionBillingScope: subscriptionBillingScope
    subscriptionWorkload: 'Production'
    subscriptionManagementGroupAssociationEnabled: true
    subscriptionManagementGroupId: '${orgPrefix}-management'
    subscriptionTags: union(namingOutput.commonTags, {
      Workload: 'management'
      CostCenter: 'CC-PLATFORM'
    })
    roleAssignmentEnabled: false
    roleAssignments: []
  }
}

// ============================================================
// 出力値
// ============================================================
@description('Connectivity サブスクリプション ID')
output connectivitySubscriptionId string = subVendingConnectivity.outputs.subscriptionId

@description('Management サブスクリプション ID')
output managementSubscriptionId string = subVendingManagement.outputs.subscriptionId
