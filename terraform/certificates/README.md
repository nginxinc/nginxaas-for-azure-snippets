# Manage an NGINXaaS for Azure deployment certificate.

### Usage

The code in this directory can be used to managed an **NGINXaaS for Azure deployment certificate**.

To create a deployment, add a certificate, and leverage it in a configuration, run the following commands:

```shell
terraform init
terraform plan
terraform apply --auto-approve
```

Once the deployment is no longer needed, run the following to clean up the deployment and related resources:

```shell
terraform destroy --auto-approve
```
