# Manage an NGINXaaS for Azure deployment with diagnostic setting for logging.

### Usage

The code in this directory can be used to manage an **NGINXaaS for Azure deployment**.

To create a deployment with diagnostic setting for logging, run the following commands:

```shell
terraform init
terraform plan -var="storage_account_resource_group=myresourcegroup" -var="storage_account_name=myaccountname" -out=plan.cache
terraform apply plan.cache
```

Once the deployment is no longer needed, run the following to clean up the deployment and related resources:

```shell
terraform destroy --auto-approve
```
