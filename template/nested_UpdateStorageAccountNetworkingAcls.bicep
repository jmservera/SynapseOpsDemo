param storageLocation string
param defaultDataLakeStorageAccountName string
param workspaceStorageAccountProperties object

resource defaultDataLakeStorageAccountName_resource 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  location: storageLocation
  name: defaultDataLakeStorageAccountName
  properties: workspaceStorageAccountProperties
}