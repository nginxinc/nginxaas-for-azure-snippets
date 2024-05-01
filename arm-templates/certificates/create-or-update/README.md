---
description: Create or update an NGINXaaS for Azure certificate for a NGINX deployment using an existing certificate in an Azure Key Vault.
languages:
- json
- bicep
---

# Add an NGINXaaS for Azure deployment certificate.

## Prerequisites
- [NGINX documentation](https://docs.nginx.com/nginxaas/azure/management/ssl-tls-certificates/)
    - [Deployment with user assigned managed identity quickstart template](../../deployments/with-userassigned-identity/README.md)
    
## Usage
```
az keyvault certificate create --vault-name myVault -n myCert \
    -p "$(az keyvault certificate get-default-policy)"
az deployment group create  --name myName  --resource-group myGroup --template-file azdeploy.json \
    --parameters certificateName=myCert keyVaultSecretId=https://myVault.vault.azure.net/secrets/myCert
```

This template provides a way to deploy a **NGINX Deployment Certificate** to a **NGINX Deployment**.

If you're new to **NGINXaaS for Azure**, see:

- [NGINXaaS for Azure documentation](https://docs.nginx.com/nginxaas/azure/)


If you're new to **Azure Key Vault**, see:

- [Azure Key Vault service](https://azure.microsoft.com/services/key-vault/)
- [Azure Key Vault documentation](https://docs.microsoft.com/azure/key-vault/)
- [Azure Key Vault template reference](https://docs.microsoft.com/azure/templates/microsoft.keyvault/allversions)


If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
