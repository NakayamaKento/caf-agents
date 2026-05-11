targetScope = 'tenant'

// ============================================================
// 管理グループ階層の作成（最小実装）
// caf-ready-landing-zone/bicep/modules/management-groups.bicep
// ============================================================
// 参考: https://learn.microsoft.com/ja-jp/azure/cloud-adoption-framework/ready/landing-zone/

@description('組織の接頭辞（英小文字・数字、2〜8 文字）')
@minLength(2)
@maxLength(8)
param orgPrefix string

@description('テナントルート直下の親管理グループ ID')
param managementGroupRootId string

// ============================================================
// ルート管理グループ（組織ルート）
// ============================================================
resource mgRoot 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: '${orgPrefix}-root'
  properties: {
    displayName: '${orgPrefix} - Root'
    details: {
      parent: {
        id: tenantResourceId('Microsoft.Management/managementGroups', managementGroupRootId)
      }
    }
  }
}

// ============================================================
// Platform 管理グループ
// ============================================================
resource mgPlatform 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: '${orgPrefix}-platform'
  properties: {
    displayName: '${orgPrefix} - Platform'
    details: {
      parent: {
        id: mgRoot.id
      }
    }
  }
  dependsOn: [mgRoot]
}

resource mgManagement 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: '${orgPrefix}-management'
  properties: {
    displayName: '${orgPrefix} - Management'
    details: {
      parent: {
        id: mgPlatform.id
      }
    }
  }
  dependsOn: [mgPlatform]
}

resource mgConnectivity 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: '${orgPrefix}-connectivity'
  properties: {
    displayName: '${orgPrefix} - Connectivity'
    details: {
      parent: {
        id: mgPlatform.id
      }
    }
  }
  dependsOn: [mgPlatform]
}

resource mgIdentity 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: '${orgPrefix}-identity'
  properties: {
    displayName: '${orgPrefix} - Identity'
    details: {
      parent: {
        id: mgPlatform.id
      }
    }
  }
  dependsOn: [mgPlatform]
}

// ============================================================
// Landing Zones 管理グループ
// ============================================================
resource mgLandingZones 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: '${orgPrefix}-landingzones'
  properties: {
    displayName: '${orgPrefix} - Landing Zones'
    details: {
      parent: {
        id: mgRoot.id
      }
    }
  }
  dependsOn: [mgRoot]
}

resource mgCorp 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: '${orgPrefix}-corp'
  properties: {
    displayName: '${orgPrefix} - Corp'
    details: {
      parent: {
        id: mgLandingZones.id
      }
    }
  }
  dependsOn: [mgLandingZones]
}

resource mgOnline 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: '${orgPrefix}-online'
  properties: {
    displayName: '${orgPrefix} - Online'
    details: {
      parent: {
        id: mgLandingZones.id
      }
    }
  }
  dependsOn: [mgLandingZones]
}

// ============================================================
// Sandbox / Decommissioned 管理グループ
// ============================================================
resource mgSandbox 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: '${orgPrefix}-sandbox'
  properties: {
    displayName: '${orgPrefix} - Sandbox'
    details: {
      parent: {
        id: mgRoot.id
      }
    }
  }
  dependsOn: [mgRoot]
}

resource mgDecommissioned 'Microsoft.Management/managementGroups@2023-04-01' = {
  name: '${orgPrefix}-decommissioned'
  properties: {
    displayName: '${orgPrefix} - Decommissioned'
    details: {
      parent: {
        id: mgRoot.id
      }
    }
  }
  dependsOn: [mgRoot]
}

// ============================================================
// 出力値
// ============================================================
@description('組織ルート管理グループ ID')
output rootManagementGroupId string = mgRoot.id

@description('Platform 管理グループ ID')
output platformManagementGroupId string = mgPlatform.id

@description('Management 管理グループ ID')
output managementManagementGroupId string = mgManagement.id

@description('Connectivity 管理グループ ID')
output connectivityManagementGroupId string = mgConnectivity.id

@description('Identity 管理グループ ID')
output identityManagementGroupId string = mgIdentity.id

@description('Landing Zones 管理グループ ID')
output landingZonesManagementGroupId string = mgLandingZones.id

@description('Corp 管理グループ ID')
output corpManagementGroupId string = mgCorp.id

@description('Online 管理グループ ID')
output onlineManagementGroupId string = mgOnline.id

@description('Sandbox 管理グループ ID')
output sandboxManagementGroupId string = mgSandbox.id

@description('Decommissioned 管理グループ ID')
output decommissionedManagementGroupId string = mgDecommissioned.id
