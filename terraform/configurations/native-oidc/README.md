# Manage an NGINXaaS for Azure deployment with OIDC Configuration.

## Overview

This example demonstrates how to deploy NGINXaaS for Azure with a native OIDC configuration using Terraform. It provisions all required Azure resources, configures NGINXaaS, and attaches a certificate for secure communication.

## Features

- Deploys NGINXaaS for Azure with a custom configuration supporting OIDC authentication.
- Provisions a Key Vault and generates a self-signed certificate.
- Assigns required roles for certificate access.
- Attaches the certificate to the NGINXaaS deployment.
- Demonstrates how to reference the certificate in your NGINX configuration.

## Usage

To create a deployment and add a configuration, run the following commands:

```shell
terraform init
terraform plan
terraform apply --auto-approve
```

Once the deployment is no longer needed, run the following to clean up the deployment and related resources:

```shell
terraform destroy --auto-approve
```

## Prerequisites

- Configure SSL/TLS Certificates.
- Configure the IdP. This example configuration is using the [Microsoft Entra ID](https://docs.nginx.com/nginx/deployment-guides/single-sign-on/entra-id/). For more information,    please look at [different OIDC Provider Servers and Services](https://docs.nginx.com/nginx/deployment-guides/single-sign-on/).
- Please provide the issuer_url, client_id, client_secret values using the terraform.tfvars as shown in terraform.tfvars.example .

## Notes

- The deployment uses a self-signed certificate for demonstration. For production, use a certificate issued by a trusted CA.
- OIDC configuration requires NGINX Plus R34 or later.
- For more details on how to configure the OIDC in NGINXaaS, please refer to the references below
   - https://docs.nginx.com/nginx/deployment-guides/single-sign-on/entra-id/
   - https://docs.nginx.com/nginxaas/azure/quickstart/runtime-state-sharing/
   - https://docs.nginx.com/nginx/releases/#r34
   - https://community.f5.com/kb/technicalarticles/f5-nginx-plus-r34-release-now-available/340300
   - https://nginx.org/en/docs/http/ngx_http_oidc_module.html
   - https://docs.nginx.com/nginxaas/azure/getting-started/ssl-tls-certificates/


