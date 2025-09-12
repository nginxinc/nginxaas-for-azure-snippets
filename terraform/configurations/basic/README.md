# Manage an NGINXaaS for Azure deployment configuration.

### Usage

The code in this directory can be used to managed an **NGINXaaS for Azure deployment configuration**.

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
