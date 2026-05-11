targetScope = 'subscription'

// ============================================================
// エントリポイント — サブスクリプションスコープ
// caf-ready-landing-zone/bicep/main.bicep
// ============================================================

@description('デプロイ先のリージョン（管理グループ作成はグローバルだが、リソース作成に使用）')
param location string = 'japaneast'

@description('環境名')
@allowed(['dev', 'staging', 'prod'])
param environmentName string

@description('組織の接頭辞（英小文字・数字、2〜8 文字）')
@minLength(2)
@maxLength(8)
param orgPrefix string

@description('テナントルート直下の管理グループ ID（既存 MG の ID を指定）')
param managementGroupRootId string

@description('デプロイ日時スタンプ（べき等性確保用）')
param deploymentTimestamp string = utcNow('yyyyMMdd-HHmmss')

// ------------------------------------------------------------
// 命名規則モジュール
// ------------------------------------------------------------
module naming 'modules/naming.bicep' = {
  name: 'naming-${deploymentTimestamp}'
  params: {
    orgPrefix: orgPrefix
    environmentName: environmentName
    location: location
  }
}

// ------------------------------------------------------------
// 管理グループ階層
// ------------------------------------------------------------
// 注意: 管理グループはテナントスコープのリソースです。
//       このモジュールを直接呼び出すには、テナントスコープのデプロイが必要です。
//       通常は事前に次のコマンドで管理グループを別途デプロイしてください:
//       az deployment tenant create \
//         --location japaneast \
//         --template-file bicep/modules/management-groups.bicep \
//         --parameters orgPrefix=<orgPrefix> managementGroupRootId=<rootMGId>
//
// 以下の変数は管理グループが作成済みの前提で参照します。
var corpManagementGroupId = '${orgPrefix}-corp'
var onlineManagementGroupId = '${orgPrefix}-online'

// ------------------------------------------------------------
// Landing Zone — サブスクリプション自動発行（Sub Vending）
// avm/ptn/lz/sub-vending を呼び出すラッパー
// ------------------------------------------------------------
module subVending 'lz/sub-vending.bicep' = {
  name: 'sub-vending-${deploymentTimestamp}'
  params: {
    location: location
    environmentName: environmentName
    orgPrefix: orgPrefix
    namingOutput: naming.outputs
    corpManagementGroupId: corpManagementGroupId
    onlineManagementGroupId: onlineManagementGroupId
  }
}

// ------------------------------------------------------------
// Hub ネットワーキング（Connectivity サブスクリプション）
// avm/ptn/network/hub-networking を呼び出すラッパー
// ------------------------------------------------------------
module hubNetworking 'lz/hub-networking.bicep' = {
  name: 'hub-networking-${deploymentTimestamp}'
  params: {
    location: location
    environmentName: environmentName
    orgPrefix: orgPrefix
    namingOutput: naming.outputs
    connectivitySubscriptionId: subVending.outputs.connectivitySubscriptionId
  }
  dependsOn: [
    subVending
  ]
}

// ------------------------------------------------------------
// ポリシー Initiative の定義と割当
// ------------------------------------------------------------
// 注意: initiative.bicep は managementGroup スコープのリソースです。
//       このモジュールを直接呼び出すには管理グループスコープのデプロイが必要です。
//       次のコマンドで別途デプロイしてください:
//       az deployment mg create \
//         --management-group-id <orgPrefix>-root \
//         --location japaneast \
//         --template-file bicep/policy/initiative.bicep \
//         --parameters orgPrefix=<orgPrefix> environmentName=<env> managementGroupRootId=<rootMGId>

// ============================================================
// 出力値
// ============================================================
@description('命名規則出力')
output namingOutputs object = naming.outputs

@description('Hub ネットワーキング出力')
output hubNetworkingOutputs object = hubNetworking.outputs
