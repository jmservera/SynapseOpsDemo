param reference_concat_Microsoft_Synapse_workspaces_parameters_name_2021_06_01_Full_identity_principalId object
param resourceId_Microsoft_Authorization_roleDefinitions_variables_storageBlobDataContributorRoleID string
param variables_storageBlobDataContributorRoleID string /* TODO: fill in correct type */
param defaultDataLakeStorageAccountName string
param name string
param storageRoleUniqueId string
param storageLocation string
param setSbdcRbacOnStorageAccount bool
param userObjectId string

resource defaultDataLakeStorageAccountName_Microsoft_Authorization_id_variables_storageBlobDataContributorRoleID_name_storageRoleUniqueId 'Microsoft.Storage/storageAccounts/providers/roleAssignments@2018-09-01-preview' = {
  name: '${defaultDataLakeStorageAccountName}/Microsoft.Authorization/${guid('${resourceGroup().id}/${variables_storageBlobDataContributorRoleID}/${name}/${storageRoleUniqueId}')}'
  location: storageLocation
  properties: {
    roleDefinitionId: resourceId_Microsoft_Authorization_roleDefinitions_variables_storageBlobDataContributorRoleID
    principalId: reference_concat_Microsoft_Synapse_workspaces_parameters_name_2021_06_01_Full_identity_principalId.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource defaultDataLakeStorageAccountName_Microsoft_Authorization_id_variables_storageBlobDataContributorRoleID_userObjectId_storageRoleUniqueId 'Microsoft.Storage/storageAccounts/providers/roleAssignments@2018-09-01-preview' = if (setSbdcRbacOnStorageAccount) {
  name: '${defaultDataLakeStorageAccountName}/Microsoft.Authorization/${guid('${resourceGroup().id}/${variables_storageBlobDataContributorRoleID}/${userObjectId}/${storageRoleUniqueId}')}'
  properties: {
    roleDefinitionId: resourceId_Microsoft_Authorization_roleDefinitions_variables_storageBlobDataContributorRoleID
    principalId: userObjectId
    principalType: 'User'
  }
}
