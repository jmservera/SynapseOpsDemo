# SynapseOpsDemo
DataOps demo

## Create a Synapse Workspace from an issue

This repo uses the new [GitHub Forms feature](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms) to provide a template for creating an issue, that will automatically create a Synapse workspace from the stored template in the repo.
If you want to try this, you can fork this repo and create an environment with these secrets:

| name | description
| --- | ---
| AZURE_CREDENTIALS | A json created from the `az ad create-for-rbac --sdk` command
| CLIENTID | The same id created with the previous command
| CLIENTSECRET | The secret obtained from the previous command
| SUBSCRIPTIONID | The Azure Subscription ID 
| TENANTID | The AAD TenantID, the same one from the credentials
| OBJECTID | The ID for the user or group in AAD that will have permissions for the Synapse Workspace (this is usually your id in AAD)
| SQL_SERVER | The SQL password you will use to get access to the Synapse Workspace using SSMS or any other similar tool, the default user is `sqladminuser`

## AZURE_CREDENTIALS requirements

To create an Azure Synapse workspace, a user must have Azure Contributor role and User Access Administrator permissions, or the Owner role in the subscription. You will need to perform the following steps:

1. First you need to create a service principal in Azure, copy the credentials from the Azure portal and paste them in the `AZURE_CREDENTIALS` environment variable. It is better if you chop the new line characters (`\n`) from the json, so it will be simpler if you run this command at the azure CLI:

    ```bash
    az ad sp create-for-rbac --name {myApp} --role contributor --scopes /subscriptions/{subscription-id}/resourceGroups/{exampleRG} --sdk-auth | tr -d '\n'
    ```

    You can paste the json output from this command into the AZURE_CREDENTIALS variable.

2. Then you need to add permissions to the service principal.

    ```bash
    az role assignment create --assignee {object-id} --role 'User Access Administrator' --scope /subscriptions/{subscription-id}
    ```


Then go to create a [new issue](../../issues/new?assignees=&labels=resource+creation&template=create-synapse-environment.yml&title=%5BCreate%5D%3A+) and fill the form to automatically create a new Synapse environment.


## Test the embedded template

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjmenterprisedemo%2FSynapseOpsDemo%2Fmain%2Ftemplate%2Ftemplate.json) [![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fjmenterprisedemo%2FSynapseOpsDemo%2Fmain%2Ftemplate%2Ftemplate.json)
