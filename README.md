# NGINX For Azure Snippets

This repository contains code snippets for common [NGINX for Azure](https://docs.nginx.com/nginx-for-azure/) use cases. These snippets can be leveraged in applications or as infrastructure as code and in CI workflows to automate the creation or update of NGINX for Azure deployment resources.

### Connecting to Azure

These snippets require an authenticated Azure Resource Manager client like the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/) or [Az Powershell](https://docs.microsoft.com/en-us/powershell/azure/?view=azps-8.2.0)

* [Sign in with Azure CLI](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli)
* [Sign in with Azure PowerShell](https://docs.microsoft.com/en-us/powershell/azure/authenticate-azureps?view=azps-8.2.0)
* [Authenticate Terraform to Azure](https://docs.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash)

### Code Snippets

* [ARM Template](./snippets/arm-templates/README.md)
* [Python SDK](snippets/sdk/python/README.md)
* [Terraform](snippets/terraform/README.md)
