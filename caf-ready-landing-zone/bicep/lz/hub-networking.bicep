targetScope = 'subscription'

// ============================================================
// Hub Networking ラッパー
// Azure Verified Modules: avm/ptn/network/hub-networking
// caf-ready-landing-zone/bicep/lz/hub-networking.bicep
// ============================================================
// AVM 参照: https://github.com/Azure/bicep-registry-modules/tree/main/avm/ptn/network/hub-networking

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

@description('Connectivity サブスクリプション ID')
param connectivitySubscriptionId string

// ============================================================
// Hub ネットワーク用リソースグループ
// ============================================================
resource rgConnectivity 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'rg-connectivity-${environmentName}-${namingOutput.regionAbbr}'
  location: location
  tags: union(namingOutput.commonTags, {
    Workload: 'connectivity'
    CostCenter: 'CC-PLATFORM'
  })
}

// ============================================================
// AVM — avm/ptn/network/hub-networking
// Hub VNet、Azure Firewall、VPN/ExpressRoute GW、Bastion、DNS を一括構築
// ============================================================
module hubNetworking 'br/public:avm/ptn/network/hub-networking:0.1.3' = {
  name: 'hub-networking'
  scope: rgConnectivity
  params: {
    location: location

    // Hub VNet の設定
    hubVirtualNetworkName: 'vnet-hub-${environmentName}-${namingOutput.regionAbbr}'
    hubVirtualNetworkAddressPrefix: '10.0.0.0/16'

    // Azure Firewall の有効化
    azureFirewallEnabled: true
    azureFirewallName: 'afw-hub-${environmentName}-${namingOutput.regionAbbr}'
    azureFirewallSubnetAddressPrefix: '10.0.0.0/26'
    azureFirewallPublicIpName: 'pip-afw-hub-${environmentName}-${namingOutput.regionAbbr}'

    // Azure Bastion の有効化
    bastionEnabled: true
    bastionName: 'bas-hub-${environmentName}-${namingOutput.regionAbbr}'
    bastionSubnetAddressPrefix: '10.0.1.0/26'
    bastionPublicIpName: 'pip-bas-hub-${environmentName}-${namingOutput.regionAbbr}'

    // VPN Gateway（本番環境のみ有効化）
    vpnGatewayEnabled: environmentName == 'prod'
    vpnGatewayName: 'vpng-hub-${environmentName}-${namingOutput.regionAbbr}'
    vpnGatewaySubnetAddressPrefix: '10.0.2.0/27'
    vpnGatewayPublicIpName: 'pip-vpng-hub-${environmentName}-${namingOutput.regionAbbr}'

    // Private DNS Zones（主要な Azure サービス）
    privateDnsZonesEnabled: true
    privateDnsZones: [
      'privatelink.blob.core.windows.net'
      'privatelink.file.core.windows.net'
      'privatelink.vaultcore.azure.net'
      'privatelink.database.windows.net'
      'privatelink.azurewebsites.net'
      'privatelink${environment().suffixes.sqlServerHostname}'
    ]

    // タグ
    tags: union(namingOutput.commonTags, {
      Workload: 'hub-networking'
      CostCenter: 'CC-PLATFORM'
    })

    // Lock（本番環境はリソース削除を防止）
    lock: environmentName == 'prod' ? {
      kind: 'CanNotDelete'
      name: 'lock-hub-network-prod'
    } : null
  }
}

// ============================================================
// 出力値
// ============================================================
@description('Hub VNet リソース ID')
output hubVnetId string = hubNetworking.outputs.hubVirtualNetworkResourceId

@description('Azure Firewall プライベート IP')
output firewallPrivateIpAddress string = hubNetworking.outputs.azureFirewallPrivateIpAddress

@description('Hub リソースグループ名')
output resourceGroupName string = rgConnectivity.name
