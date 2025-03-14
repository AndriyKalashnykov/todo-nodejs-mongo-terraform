# React Web App with Node.js API and MongoDB (Terraform) on Azure

[![Open in GitHub Codespaces](https://img.shields.io/static/v1?style=for-the-badge&label=GitHub+Codespaces&message=Open&color=brightgreen&logo=github)](https://codespaces.new/azure-samples/todo-nodejs-mongo-terraform)
[![Open in Dev Container](https://img.shields.io/static/v1?style=for-the-badge&label=Dev+Containers&message=Open&color=blue&logo=visualstudiocode)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/AndriyKalashnykov/todo-nodejs-mongo-terraform)

A blueprint for getting a React web app with a Node.js API and a MongoDB database running on Azure. The blueprint includes sample application code (a ToDo web app) which can be removed and replaced with your own application code. Add your own source code and leverage the Infrastructure as Code assets (written in Terraform) to get up and running quickly.

Let's jump in and get this up and running in Azure. When you are finished, you will have a fully functional web app deployed to the cloud. In later steps, you'll see how to setup a pipeline and monitor the application.

!["Screenshot of deployed ToDo app"](assets/web.png)

<sup>Screenshot of the deployed ToDo app</sup>

### Prerequisites
> This template will create infrastructure and deploy code to Azure. If you don't have an Azure Subscription, you can sign up for a [free account here](https://azure.microsoft.com/free/). Make sure you have contributor role to the Azure subscription.

The following prerequisites are required to use this application. Please ensure that you have them all installed locally.

- [Azure Developer CLI](https://aka.ms/azd-install)
- [Node.js with npm (18.17.1+)](https://nodejs.org/) - for API backend and Web frontend
- [Terraform CLI](https://aka.ms/azure-dev/terraform-install)
    - Requires the [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)

### Quickstart
To learn how to get started with any template, follow the steps in [this quickstart](https://learn.microsoft.com/azure/developer/azure-developer-cli/get-started?tabs=localinstall&pivots=programming-language-nodejs) with this template(`Azure-Samples/todo-nodejs-mongo-terraform`)

This quickstart will show you how to authenticate on Azure, initialize using a template, provision infrastructure and deploy code on Azure via the following commands:

```bash
# Log in to azd. Only required once per-install.
azd auth login

# First-time project setup. Initialize a project in the current directory, using this template. 
# azd init --template AndriyKalashnykov/todo-nodejs-mongo-terraform --no-prompt

#
# Configure remote state storage account - https://github.com/MicrosoftDocs/azure-dev-docs/blob/main/articles/terraform/store-state-in-azure-storage.md#azure-cli
#
#!/bin/bash

# RESOURCE_GROUP_NAME=tfstate
# STORAGE_ACCOUNT_NAME=tfstate$RANDOM
# CONTAINER_NAME=tfstate

# # Create resource group
# az group create --name $RESOURCE_GROUP_NAME --location eastus

# # Create storage account
# az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# # Create blob container
# az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME

azd env set RS_RESOURCE_GROUP tfstate-rg
azd env set RS_STORAGE_ACCOUNT tfstate29056
azd env set RS_CONTAINER_NAME tfstate

# Provision and deploy to Azure
azd up
```

### Use APIs

```bash
source <(azd env get-values)

curl -X POST "$API_URI/api/GenerateAPIx"

az keyvault key delete --vault-name kv-n2m1njk5mwq3z --name 4ea92dfb-2091-40e3-ab1f-5b33097e1285

az keyvault delete --name kv-n2m1njk5mwq3z
az keyvault purge --name kv-n2m1njk5mwq3z

az keyvault key list --vault-name kv-n2m1njk5mwq3z
/subscriptions/d57e7e81-e648-45d6-83cc-b304be945e86/resourceGroups/rg-dev/providers/Microsoft.KeyVault/vaults/kv-n2m1njk5mwq3z/objectId/4ea92dfb-2091-40e3-ab1f-5b33097e1285
```

### Application Architecture

This application utilizes the following Azure resources:

- [**Azure App Services**](https://docs.microsoft.com/azure/app-service/) to host the Web frontend and API backend
- [**Azure Cosmos DB API for MongoDB**](https://docs.microsoft.com/azure/cosmos-db/mongodb/mongodb-introduction) for storage
- [**Azure Monitor**](https://docs.microsoft.com/azure/azure-monitor/) for monitoring and logging
- [**Azure Key Vault**](https://docs.microsoft.com/azure/key-vault/) for securing secrets

Here's a high level architecture diagram that illustrates these components. Notice that these are all contained within a single [resource group](https://docs.microsoft.com/azure/azure-resource-manager/management/manage-resource-groups-portal), that will be created for you when you create the resources.

!["Application architecture diagram"](assets/resources.png)

> This template provisions resources to an Azure subscription that you will select upon provisioning them. Please refer to the [Pricing calculator for Microsoft Azure](https://azure.microsoft.com/pricing/calculator/) and, if needed, update the included Azure resource definitions found in `infra/main.bicep` to suit your needs.

### Application Code

This template is structured to follow the [Azure Developer CLI](https://aka.ms/azure-dev/overview). You can learn more about `azd` architecture in [the official documentation](https://learn.microsoft.com/azure/developer/azure-developer-cli/make-azd-compatible?pivots=azd-create#understand-the-azd-architecture).

### Next Steps

At this point, you have a complete application deployed on Azure. But there is much more that the Azure Developer CLI can do. These next steps will introduce you to additional commands that will make creating applications on Azure much easier. Using the Azure Developer CLI, you can setup your pipelines, monitor your application, test and debug locally.

- [`azd pipeline config`](https://learn.microsoft.com/azure/developer/azure-developer-cli/configure-devops-pipeline?tabs=GitHub) - to configure a CI/CD pipeline (using GitHub Actions or Azure DevOps) to deploy your application whenever code is pushed to the main branch. 

> Note: Needs to manually install [setup-azd extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.azd) for Azure DevOps (azdo).

- [`azd monitor`](https://learn.microsoft.com/azure/developer/azure-developer-cli/monitor-your-app) - to monitor the application and quickly navigate to the various Application Insights dashboards (e.g. overview, live metrics, logs)

- [Run and Debug Locally](https://learn.microsoft.com/azure/developer/azure-developer-cli/debug?pivots=ide-vs-code) - using Visual Studio Code and the Azure Developer CLI extension

- [`azd down`](https://learn.microsoft.com/azure/developer/azure-developer-cli/reference#azd-down) - to delete all the Azure resources created with this template
```bash
azd down --force --purge
```

- [Enable optional features, like APIM](./OPTIONAL_FEATURES.md) - for enhanced backend API protection and observability

### Additional `azd` commands

The Azure Developer CLI includes many other commands to help with your Azure development experience. You can view these commands at the terminal by running `azd help`. You can also view the full list of commands on our [Azure Developer CLI command](https://aka.ms/azure-dev/ref) page.

## Security

### Roles

This template creates a [managed identity](https://docs.microsoft.com/azure/active-directory/managed-identities-azure-resources/overview) for your app inside your Azure Active Directory tenant, and it is used to authenticate your app with Azure and other services that support Azure AD authentication like Key Vault via access policies. You will see principalId referenced in the infrastructure as code files, that refers to the id of the currently logged in Azure Developer CLI user, which will be granted access policies and permissions to run the application locally. To view your managed identity in the Azure Portal, follow these [steps](https://docs.microsoft.com/azure/active-directory/managed-identities-azure-resources/how-to-view-managed-identity-service-principal-portal).

### Key Vault

This template uses [Azure Key Vault](https://docs.microsoft.com/azure/key-vault/general/overview) to securely store your Cosmos DB connection string for the provisioned Cosmos DB account. Key Vault is a cloud service for securely storing and accessing secrets (API keys, passwords, certificates, cryptographic keys) and makes it simple to give other Azure services access to them. As you continue developing your solution, you may add as many secrets to your Key Vault as you require.

## Reporting Issues and Feedback

If you have any feature requests, issues, or areas for improvement, please [file an issue](https://aka.ms/azure-dev/issues). To keep up-to-date, ask questions, or share suggestions, join our [GitHub Discussions](https://aka.ms/azure-dev/discussions). You may also contact us via AzDevTeam@microsoft.com.

### Resources

* [Original article](https://learn.microsoft.com/en-us/samples/azure-samples/todo-nodejs-mongo-terraform/todo-nodejs-mongo-terraform/)
* [Original repo](https://github.com/azure-samples/todo-nodejs-mongo-terraform/tree/main/)
* [Use Terraform as an infrastructure as code tool for Azure Developer CLI](https://github.com/MicrosoftDocs/azure-dev-docs/blob/main/articles/azure-developer-cli/use-terraform-for-azd.md)
* [Store Terraform state in Azure Storage](https://github.com/MicrosoftDocs/azure-dev-docs/blob/main/articles/terraform/store-state-in-azure-storage.md)
* [Soft-delete will be enabled on all key vaults](https://docs.azure.cn/en-us/key-vault/general/soft-delete-change)
* [How to set the value of an Azure KeyVault secret using curl](https://stackoverflow.com/questions/51440297/how-to-set-the-value-of-an-azure-keyvault-secret-using-curl)
* [Manage Key Vault using the Azure CLI](https://learn.microsoft.com/en-us/azure/key-vault/general/manage-with-cli2)
* [Manage Azure Cosmos DB for NoSQL resources with terraform](https://learn.microsoft.com/en-us/azure/cosmos-db/nosql/manage-with-terraform)
* [Quickstart: Deploy an Azure Cosmos DB to Azure Container Instances](https://learn.microsoft.com/en-us/azure/developer/terraform/azurerm/deploy-azure-cosmos-db-to-azure-container-instances)
* [azurerm azurerm_cosmosdb_account 3.117.0](https://registry.terraform.io/providers/hashicorp/azurerm/3.117.0/docs/resources/cosmosdb_account#primary_mongodb_connection_string-1)
* [azurerm azurerm_cosmosdb_account 4.16.0](https://registry.terraform.io/providers/hashicorp/azurerm/4.16.0/docs/resources/cosmosdb_account)
