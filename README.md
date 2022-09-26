# NGINX For Azure Snippets

This repository contains code snippets and templates for common [NGINX for Azure](https://docs.nginx.com/nginx-for-azure/) use cases. These snippets and templates can be leveraged in applications or as infrastructure as code and in CI workflows to automate the creation or update of NGINX for Azure deployment resources.

### Connecting to Azure
These snippets require an authenticated Azure Resource Manager client like the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/) or [Az Powershell](https://docs.microsoft.com/en-us/powershell/azure/?view=azps-8.2.0)
*  [Sign in with Azure CLI](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli)
*  [Sign in with Azure PowerShell](https://docs.microsoft.com/en-us/powershell/azure/authenticate-azureps?view=azps-8.2.0)
*  [Authenticate Terraform to Azure](https://docs.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash)


### Sample Usage
```bash
$ az login
$ cd snippets/templates/deployments/prerequisites
$ az deployment group create --name myPrerequisites  --resource-group myGroup --template-file azdeploy.json \
    --parameters subnetName=mySubnet virtualNetworkName=myVnet publicIPName=myPublicIP networkSecurityGroupName=myNsg \
    virtualNetworkAddressPrefix=10.0.0.0/16 subnetAddressPrefix=10.0.0.0/24
$ cd ../create-or-update
$ az deployment group create --name myNginxDeployment  --resource-group myGroup --template-file azdeploy.json \
    --parameters subnetName=mySubnet virtualNetworkName=myVnet publicIPName=myPublicIP
```
