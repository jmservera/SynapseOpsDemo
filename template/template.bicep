param name string
param location string = resourceGroup().location

param sqlAdministratorLogin string = 'sqladminuser'
@secure()
param sqlAdministratorLoginPassword string = ''


param defaultDataLakeStorageAccountName string
param defaultDataLakeStorageFilesystemName string

param setWorkspaceIdentityRbacOnStorageAccount bool = false
param createManagedPrivateEndpoint bool = false
param defaultAdlsGen2AccountResourceId string = ''
param azureADOnlyAuthentication bool = false
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
param storageSubscriptionID string = subscription().subscriptionId
param storageResourceGroupName string = resourceGroup().name
param storageLocation string = resourceGroup().location
param storageRoleUniqueId string = newGuid()
param isNewStorageAccount bool = true
param isNewFileSystemOnly bool = true
param managedResourceGroupName string = ''

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

@description('Indicates the type of storage account.')
@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'Storage'
  'StorageV2'
])
param storageKind string = 'StorageV2'
@description('Set the minimum TLS version to be permitted on requests to storage. The default interpretation is TLS 1.2 for this property.')
@allowed([
  'TLS1_0'
  'TLS1_1'
  'TLS1_2'
])
param minimumTlsVersion string = 'TLS1_2'
param userObjectId string = ''
param setSbdcRbacOnStorageAccount bool = false

var storageBlobDataContributorRoleID = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
// var unique = uniqueString(resourceGroup().id)

var defaultDataLakeStorageAccountUrl = 'https://${defaultDataLakeStorageAccountName}.dfs.${environment().suffixes.storage}'

resource name_resource 'Microsoft.Synapse/workspaces@2021-06-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      accountUrl: defaultDataLakeStorageAccountUrl
      filesystem: defaultDataLakeStorageFilesystemName
      resourceId: defaultAdlsGen2AccountResourceId
      createManagedPrivateEndpoint: createManagedPrivateEndpoint
    }
    managedVirtualNetwork: managedVirtualNetwork
    managedResourceGroupName: managedResourceGroupName
    publicNetworkAccess: publicNetworkAccess
    azureADOnlyAuthentication: azureADOnlyAuthentication
    sqlAdministratorLogin: sqlAdministratorLogin
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
  }
  dependsOn: [
    defaultDataLakeStorageAccountName_resource
    defaultDataLakeStorageFilesystemName_resource
  ]
}

resource name_allowAll 'Microsoft.Synapse/workspaces/firewallrules@2021-06-01' = if (allowAllConnections) {
  parent: name_resource
  name: 'allowAll'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

module StorageRoleDeploymentResource './nested_StorageRoleDeploymentResource.bicep' = if (setWorkspaceIdentityRbacOnStorageAccount) {
  name: 'StorageRoleDeploymentResource'
  scope: resourceGroup(storageSubscriptionID, storageResourceGroupName)
  params: {
    reference_concat_Microsoft_Synapse_workspaces_parameters_name_2021_06_01_Full_identity_principalId: reference('Microsoft.Synapse/workspaces/${name}', '2021-06-01', 'Full')
    resourceId_Microsoft_Authorization_roleDefinitions_variables_storageBlobDataContributorRoleID: resourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleID)
    variables_storageBlobDataContributorRoleID: storageBlobDataContributorRoleID
    defaultDataLakeStorageAccountName: defaultDataLakeStorageAccountName
    name: name
    storageRoleUniqueId: storageRoleUniqueId
    storageLocation: storageLocation
    setSbdcRbacOnStorageAccount: setSbdcRbacOnStorageAccount
    userObjectId: userObjectId
  }
  dependsOn: [
    name_resource
  ]
}

resource defaultDataLakeStorageAccountName_resource 'Microsoft.Storage/storageAccounts@2021-01-01' = if (isNewStorageAccount) {
  name: defaultDataLakeStorageAccountName
  location: storageLocation
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

resource defaultDataLakeStorageAccountName_default_defaultDataLakeStorageFilesystemName 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-01-01' = if (isNewStorageAccount) {
  name: '${defaultDataLakeStorageAccountName}/default/${defaultDataLakeStorageFilesystemName}'
  properties: {
    publicAccess: 'None'
  }
  dependsOn: [
    defaultDataLakeStorageAccountName_resource
  ]
}

module defaultDataLakeStorageFilesystemName_resource './nested_defaultDataLakeStorageFilesystemName_resource.bicep' = if (isNewFileSystemOnly) {
  name: defaultDataLakeStorageFilesystemName
  scope: resourceGroup(storageSubscriptionID, storageResourceGroupName)
  params: {
    defaultDataLakeStorageAccountName: defaultDataLakeStorageAccountName
    defaultDataLakeStorageFilesystemName: defaultDataLakeStorageFilesystemName
  }
  dependsOn: [
    defaultDataLakeStorageAccountName_resource
  ]
}
