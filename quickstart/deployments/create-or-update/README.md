---
description: Create or update an NGINX for Azure deployment in a resource group associated with a public IP address.
languages:
- json
- bicep
---

# Creates an NGINX for Azure deployment.

### Usage
```
az deployment group create  --name myName  --resource-group myGroup --template-file azdeploy.json \
    --parameters subnetName=mySubnet virtualNetworkName=myVnet publicIPName=myPublicIP
```

This template provides a way to deploy a **NGINX Deployment** in a **Resource Group**. This service is still in **Public Preview**.

If you're new to **NGINX for Azure**, see:

- [NGINX for Azure Documentation](https://docs.nginx.com/nginx-for-azure/)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
