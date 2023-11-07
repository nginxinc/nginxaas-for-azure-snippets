---
description: Create or update an NGINXaaS for Azure deployment in a resource group associated with a public IP address.
languages:
- json
- bicep
---

# Create an NGINXaaS for Azure deployment with User Assigned Managed Identity

### Usage
```
az deployment group create  --name myName  --resource-group myGroup --template-file azdeploy.json \
    --parameters subnetName=mySubnet virtualNetworkName=myVnet publicIPName=myPublicIP userAssignedIdentityName=myManagedIdentity capacity=50
```

This template provides a way to deploy a **NGINX Deployment** in a **Resource Group**. This service is still in **Public Preview**.

If you're new to **NGINXaaS for Azure**, see:

- [NGINXaaS for Azure Documentation](https://docs.nginx.com/nginxaas/azure/)
- [NGINXaaS for Azure Managed Identity Documentation](https://docs.nginx.com/nginxaas/azure/management/managed-identity/)

If you're new to **Managed Identities**, see:

- [Azure Active Directory service](https://azure.microsoft.com/en-us/services/active-directory/)
- [Azure Managed Identity overview](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)
- [Azure Managed Identity template reference](https://docs.microsoft.com/en-us/azure/templates/microsoft.managedidentity/userassignedidentities)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
