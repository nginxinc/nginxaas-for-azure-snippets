---
description: Create or update an NGINXaaS for Azure deployment in a resource group associated with a private IP address.
languages:
- json
- bicep
---

# Creates an NGINXaaS for Azure deployment.

### Usage
```
az deployment group create  --name myName  --resource-group myGroup --template-file azdeploy.json \
    --parameters subnetName=mySubnet virtualNetworkName=myVnet privateIPAddress=10.0.1.4
```

This template provides a way to deploy a **NGINX Deployment** in a **Resource Group**. This service is still in **Public Preview**.

If you're new to **NGINXaaS for Azure**, see:

- [NGINXaaS for Azure Documentation](https://docs.nginx.com/nginxaas/azure/)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
