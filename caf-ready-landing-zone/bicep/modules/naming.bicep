// ============================================================
// 命名規則モジュール（接頭辞・略号の管理）
// caf-ready-landing-zone/bicep/modules/naming.bicep
// ============================================================
// .github/copilot-instructions.md の命名規則に準拠

@description('組織の接頭辞（英小文字・数字、2〜8 文字）')
@minLength(2)
@maxLength(8)
param orgPrefix string

@description('環境名')
@allowed(['dev', 'staging', 'prod'])
param environmentName string

@description('デプロイ先のリージョン')
param location string = 'japaneast'

// ============================================================
// リージョン略称マッピング
// ============================================================
var regionAbbreviations = {
  japaneast:   'jpe'
  japanwest:   'jpw'
  eastus:      'eus'
  eastus2:     'eu2'
  westus:      'wus'
  westus2:     'wu2'
  westeurope:  'weu'
  northeurope: 'neu'
  southeastasia: 'sea'
  eastasia:    'eas'
}

// 未知のリージョンは先頭 3 文字を使用（短いリージョン名にも対応）
var regionAbbr = contains(regionAbbreviations, location)
  ? regionAbbreviations[location]
  : length(location) < 3 ? location : substring(location, 0, 3)

// 環境略称
var envAbbreviations = {
  dev:     'd'
  staging: 's'
  prod:    'p'
}
var envAbbr = envAbbreviations[environmentName]

// 命名プレフィックス（主要リソース用）
var namingPrefix = '${orgPrefix}-${environmentName}'

// ============================================================
// 出力値 — 各リソース種別の命名パターン
// ============================================================
@description('基本プレフィックス（{orgPrefix}-{env}）')
output prefix string = namingPrefix

@description('リージョン略称')
output regionAbbr string = regionAbbr

@description('環境略称')
output envAbbr string = envAbbr

@description('リソースグループ命名パターン: rg-{workload}-{env}-{region}')
output resourceGroupPattern string = 'rg-WORKLOAD-${environmentName}-${regionAbbr}'

@description('仮想ネットワーク命名パターン: vnet-{workload}-{env}-{region}')
output vnetPattern string = 'vnet-WORKLOAD-${environmentName}-${regionAbbr}'

@description('Key Vault 命名パターン: kv-{workload}-{env}-{suffix}')
output keyVaultPattern string = 'kv-WORKLOAD-${envAbbr}-001'

@description('Log Analytics Workspace 命名パターン: law-{purpose}-{env}-{region}')
output logAnalyticsPattern string = 'law-PURPOSE-${environmentName}-${regionAbbr}'

@description('ストレージアカウント命名パターン: st{workload}{env}{suffix} (24文字以内)')
output storageAccountPattern string = 'stWORKLOAD${envAbbr}001'

@description('管理グループ命名パターン')
output managementGroupPattern object = {
  root:            '${orgPrefix}-root'
  platform:        '${orgPrefix}-platform'
  management:      '${orgPrefix}-management'
  connectivity:    '${orgPrefix}-connectivity'
  identity:        '${orgPrefix}-identity'
  landingZones:    '${orgPrefix}-landingzones'
  corp:            '${orgPrefix}-corp'
  online:          '${orgPrefix}-online'
  sandbox:         '${orgPrefix}-sandbox'
  decommissioned:  '${orgPrefix}-decommissioned'
}

@description('標準タグセット（全リソースに付与）')
output commonTags object = {
  Environment: environmentName
  ManagedBy:   'Bicep'
  Owner:       'platform-team'
  Repository:  'caf-ready-landing-zone'
}
