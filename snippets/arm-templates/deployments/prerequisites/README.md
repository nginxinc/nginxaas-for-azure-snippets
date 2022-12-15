---
description: Create bare minimum prerequisite resources for an NGINXaaS for Azure deployment.
languages:
- json
- bicep
---

# Create prerequisite resources for an NGINXaaS for Azure deployment.

### Usage
```
az deployment group create  --name myName  --resource-group myGroup --template-file azdeploy.json \
    --parameters subnetName=mySubnet virtualNetworkName=myVnet publicIPName=myPublicIP networkSecurityGroupName=myNsg \
    virtualNetworkAddressPrefix=10.0.0.0/16 subnetAddressPrefix=10.0.0.0/24
```

This template provides a way to deploy minimum prerequisites for an **NGINX Deployment** in a **Resource Group**.

If you're new to **NGINXaaS for Azure**, see:

- [NGINXaaS for Azure Documentation](https://docs.nginx.com/nginxaas/azure/)
- [Prerequisite Documentation](https://docs.nginx.com/nginxaas/azure/quickstart/prerequisites/)

If you're new to template deployment, see:

- [Azure Resource Manager Documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
- [Azure Virtual Networks Documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks?pivots=deployment-language-arm-template)
- [Azure Network Security Group Documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/networksecuritygroups?pivots=deployment-language-arm-template)
- [Azure Public IP Address Documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.network/publicipaddresses?pivots=deployment-language-arm-template)
