---
description: Create or update an NGINX for Azure deployment configuration using a single file in a resource group.
languages:
- json
- bicep
---

# Create an NGINX for Azure Deployment Configuration.

## Prerequisites
- Existing NGINX deployment
    - [Quickstart Template](../../deployments/create-or-update/README.md)
- If certificates are in the NGINX configuration ensure that those certificates have been added to the NGINX deployment
    - [Add Certificate Quickstart Template](../../certificates/add/README.md)

### Usage
```
az deployment group create --name myName --resource-group myGroup --template-file azdeploy.json \
    --parameters rootConfigContent=$(base64 myConfig.conf) nginxDeploymentName=myDeployment
```

This template provides a way to deploy a **NGINX Deployment Configuration** to a **NGINX Deployment**. This service is still in **Public Preview**.

If you're new to **NGINX for Azure**, see:

- [NGINX For Azure documentation](https://docs.nginx.com/nginx-for-azure/)
- [NGINX For Azure Configuration documentation](https://docs.nginx.com/nginx-for-azure/management/nginx-configuration/)

If you're new to **NGINX Configurations**, see:
- [NGINX documentation](https://nginx.org/en/docs/)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
