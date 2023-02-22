// ************** Parameters *******************

param name string

param sqlAdministratorLogin string = 'sqladminuser'

@secure()
param sqlAdministratorLoginPassword string

@description('sid for the Active Directory user or group that will be granted access to this resource.')
param userObjectId string

@description('When true adds a firewall rule to open access to any IP address, use only for testing')
param allowAllConnections bool = true

@allowed([
  'default'
  ''
])
param managedVirtualNetwork string = 'default'

@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Use this field if you need to have a specific Resource Group name for the automatically created RG where all the resources are stored.')
param managedResourceGroupName string = ''

@description('When enabled it will create a dedicated SQL Pool')
param createDedicatedPool bool = false

@description('SQL Pool collation')
param sqlPoolCollation string = 'SQL_Latin1_General_CP1_CI_AS'

@allowed([
  'DW100c'
  'DW200c'
  'DW300c'
  'DW400c'
  'DW500c'
  'DW1000c'
  'DW1500c'
  'DW2000c'
  'DW2500c'
  'DW3000c'
])
param sqlPoolSku string = 'DW100c'

param location string = resourceGroup().location

@description('The SKU name. Required for account creation; optional for update. Note that in older versions, SKU name was called accountType.')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param storageAccountType string = 'Standard_LRS'

@description('Set the minimum TLS version to be permitted on requests to storage. The default interpretation is TLS 1.2 for this property.')
@allowed([
  'TLS1_0'
  'TLS1_1'
  'TLS1_2'
])
param minimumTlsVersion string = 'TLS1_2'

@description('The id for an additional user to get access to the storage account, this is usually the Service Principal used in a CI/CD pipeline.')
param spSid string

// ************** Variables *******************

var uniqueName = substring('${name}${uniqueString(resourceGroup().id)}',0,19)
var storageName = '${uniqueName}stg'
var filesystemName = '${name}fs'
var contributorRoleID = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var ownerRoleID = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
var storageRoleUniqueId =  guid(resourceId('Microsoft.Storage/storageAccounts', name), storageName)
var storageRoleUserUniqueId = guid(resourceId('Microsoft.Storage/storageAccounts', name), userObjectId)
var storageRoleSPUniqueId = guid(resourceId('Microsoft.Storage/storageAccounts', name), spSid)
var synapseRoleUserUniqueId = guid(resourceId('Microsoft.Synapse/workspaces', name), userObjectId)
var synapseRoleIdentityUniqueId = guid(resourceId('Microsoft.Synapse/workspaces', name))
var storageKind = 'StorageV2'

// *********** Resources ***********

// Data Lake Store
resource datalake 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: storageName
  location: location
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
    isHnsEnabled: true
    minimumTlsVersion: minimumTlsVersion
  }
  sku: {
    name: storageAccountType
  }
  kind: storageKind
}


resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-01-01' = {
  name: '${storageName}/default/${filesystemName}'
  properties: {
    publicAccess: 'None'
  }
  dependsOn: [
    datalake
  ]
}

// ************* Synapse workspace *************

resource synapse 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      accountUrl: reference(storageName).primaryEndpoints.dfs
      filesystem: filesystemName
      createManagedPrivateEndpoint: true
      resourceId: datalake.id
    }
    managedVirtualNetwork: managedVirtualNetwork
    managedResourceGroupName: managedResourceGroupName
    publicNetworkAccess: publicNetworkAccess
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    azureADOnlyAuthentication: false
  }
  dependsOn: [
    container
  ]
}

resource sqlpool 'Microsoft.Synapse/workspaces/sqlPools@2021-03-01' = if(createDedicatedPool) {
  name: '${name}sql'
  location: location
  parent: synapse
  sku:{
    name: sqlPoolSku
  }
  properties:{
    collation: sqlPoolCollation
    createMode: 'Default'
  }
}

resource synapse_allowAzure 'Microsoft.Synapse/workspaces/firewallrules@2021-06-01' = {
  parent: synapse
  // DO NOT CHANGE NAME OR IP ADDRESSES
  // If you want to add this rule, the name should be explicitely this one
  name: 'AllowAllWindowsAzureIps' 
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource synapse_allowAll 'Microsoft.Synapse/workspaces/firewallrules@2021-06-01' = if (allowAllConnections) {
  parent: synapse
  name: 'allowAll'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource synapse_grant 'Microsoft.Synapse/workspaces/managedIdentitySqlControlSettings@2021-06-01' = {
  parent: synapse
  name: 'default'
  properties: {
    grantSqlControlToManagedIdentity: {
      desiredState: 'Enabled'
    }
  }
}

// Role Assignments for storage
resource synapseroleassing 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: storageRoleUniqueId
  scope: datalake
  properties:{
    principalId: synapse.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', contributorRoleID)
  }
}

resource synapseroleassigntosp 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if(spSid!='') {
  name: storageRoleSPUniqueId
  scope: datalake
  properties:{
    principalId: spSid
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', contributorRoleID)
  }
}

resource userroleassing 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: storageRoleUserUniqueId
  scope: datalake
  properties:{
    principalId: userObjectId
    principalType: 'User'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', contributorRoleID)
  }
}

// Role assignments for synapse ownership
resource synapseRoleAssignToSynapse 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: synapseRoleIdentityUniqueId
  scope: synapse
  properties:{
    principalId: synapse.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', ownerRoleID)
  }
}

resource synapseRoleAssignToUser 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: synapseRoleUserUniqueId
  scope: synapse
  properties:{
    principalId: userObjectId
    principalType: 'User'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', ownerRoleID)
  }
}

// ******** Output ********
output message string = 'Remember to grant access to the user with the command: az synapse role assignment create --workspace-name ${name} --role "Synapse SQL Administrator" --assignee [USER SID]'
output workspaceLink string = reference('Microsoft.Synapse/workspaces/${name}', '2021-06-01', 'Full').properties.connectivityEndpoints.web
output storageName string = storageName
output containerName string= filesystemName
output datalakeLink string = format('https://${storageName}.dfs.${environment().suffixes.storage}')
