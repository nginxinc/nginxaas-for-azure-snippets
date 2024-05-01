---
description: Create or update an NGINXaaS for Azure deployment configuration using multiple files in a resource group.
languages:
- json
- bicep
---

# Create an NGINXaaS for Azure deployment configuration.

## Prerequisites
- Existing NGINX deployment
    - [Quickstart Template](../../deployments/create-or-update/README.md)
- If certificates are in the NGINX configuration ensure that those certificates have been added to the NGINX deployment
    - [Add Certificate Quickstart Template](../../certificates/create-or-update/README.md)
- GNU tar installed
    - [MacOS](https://formulae.brew.sh/formula/gnu-tar) Note: this will require using 'gtar' not 'tar' as the command below shows
    - [Windows](http://gnuwin32.sourceforge.net/packages/gtar.htm)

### Usage
```
tar -cvzf config.tar.gz -C ./configs --xform s:'./':'/etc/nginx/': .

tar -tf config.tar.gz
# Should return
# ./
# /etc/nginx/nginx.conf
# /etc/nginx/conf.d/
# /etc/nginx/conf.d/proxy.conf

az deployment group create --name myName --resource-group myGroup --template-file azdeploy.json \
    --parameters tarball=$(base64 config.tar.gz) nginxDeploymentName=myDeployment
```

This template provides a way to deploy a **NGINX Deployment Configuration** to a **NGINX Deployment**.

If you're new to **NGINXaaS for Azure**, see:

- [NGINXaaS for Azure documentation](https://docs.nginx.com/nginxaas/azure/)
- [NGINXaaS for Azure Configuration documentation](https://docs.nginx.com/nginxaas/azure/management/nginx-configuration/)

If you're new to **NGINX Configurations**, see:
- [NGINX documentation](https://nginx.org/en/docs/)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
