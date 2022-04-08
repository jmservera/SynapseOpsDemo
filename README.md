# SynapseOpsDemo
DataOps demo


## Create a Synapse Workspace from an issue

This repo uses the new [GitHub Forms feature](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms) to provide a template for creating an issue, that will automatically create a Synapse workspace from the stored template in the repo.
If you want to try this, you can fork this repo and create an environment with these secrets:

| name | description
| --- | ---
| AZURE_CREDENTIALS | A json created from the `az ad create-for-rbak --sdk` command
| CLIENTID | The same id created with the previous command
| CLIENTSECRET | The secret obtained from the previous command
| SUBSCRIPTIONID | The Azure Subscription ID 
| TENANTID | The AAD TenantID, the same one from the credentials
| OBJECTID | The ID for the user or group in AAD that will have permissions for the Synapse Workspace
| SQL_SERVER | The SQL password you will use to get access to the Synapse Workspace using SSMS or any other similar tool, the default user is `sqladminuser`

Then go to create a [new issue](../issues/new?assignees=&labels=resource+creation&template=create-synapse-environment.yml&title=%5BCreate%5D%3A+) and fill the form.
