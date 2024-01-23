#! /usr/local/env python3

import os

from azure.identity import DefaultAzureCredential
from azure.mgmt.monitor import MonitorManagementClient
from azure.mgmt.nginx import NginxManagementClient
from azure.mgmt.storage import StorageManagementClient

import prerequisites


def main():
    SUBSCRIPTION_ID = os.environ.get("AZURE_SUBSCRIPTION_ID", None)
    GROUP_NAME = "myResourceGroup"
    LOCATION = "eastus"
    DEPLOYMENT_NAME = "myDeployment"
    STORAGE_ACCOUNT_NAME = "mystorageaccount12345"

    # Create clients
    # For other authentication approaches, please see: https://pypi.org/project/azure-identity/
    monitoring_client = MonitorManagementClient(
        credential=DefaultAzureCredential(), subscription_id=SUBSCRIPTION_ID
    )
    nginx_client = NginxManagementClient(
        credential=DefaultAzureCredential(), subscription_id=SUBSCRIPTION_ID
    )
    storage_client = StorageManagementClient(
        credential=DefaultAzureCredential(), subscription_id=SUBSCRIPTION_ID
    )

    # Create prerequisite resources
    subnet, public_ip, _ = prerequisites.create()

    # Create storage account
    # https://github.com/Azure-Samples/azure-samples-python-management/tree/main/samples/storage
    storage_account = storage_client.storage_accounts.begin_create(
        GROUP_NAME,
        STORAGE_ACCOUNT_NAME,
        {
            "sku": {"name": "Standard_LRS"},
            "kind": "BlobStorage",
            "location": LOCATION,
            "accessTier": "Hot",
            "encryption": {
                "services": {
                    "file": {"key_type": "Account", "enabled": True},
                    "blob": {"key_type": "Account", "enabled": True},
                },
                "key_source": "Microsoft.Storage",
            },
        },
    ).result()
    print("Created a storage account.\n")

    # Create deployment with a public IP
    deployment = nginx_client.deployments.begin_create_or_update(
        GROUP_NAME,
        DEPLOYMENT_NAME,
        {
            "sku": {"name": "standard_Monthly"},
            "tags": {"myKey": "myValue"},
            "location": LOCATION,
            "identity": {
                "type": "SystemAssigned",
            },
            "properties": {
                "enableDiagnosticSupport": True,
                "networkProfile": {
                    "networkInterfaceConfiguration": {"subnetId": subnet.id},
                    "frontendIPConfiguration": {
                        "publicIPAddresses": [{"id": public_ip.id}]
                    },
                },
                "scalingProperties": {"capacity": 20},
                "userProfile": {"preferredEmail": "user@f5.com"},
            },
        },
    ).result()
    print("Created a deployment:\n{}".format(deployment))

    # Create diagnostic setting for the deployment
    diagnostic_setting = monitoring_client.diagnostic_settings.create_or_update(
        deployment.id,
        "myDiagnosticSetting",
        {
            "storage_account_id": storage_account.id,
            "logs": [
                {
                    "category": "NginxLogs",
                    "enabled": True,
                    "retention_policy": {"enabled": False, "days": "1"},
                }
            ],
        },
    )
    print("Create diagnostic setting:\n{}".format(diagnostic_setting))

    # Delete diagnostic setting
    monitoring_client.diagnostic_settings.delete(deployment.id, "myDiagnosticSetting")
    print("Deleted diagnostic setting.\n")

    # Delete a deployment
    nginx_client.deployments.begin_delete(GROUP_NAME, DEPLOYMENT_NAME).result()
    print("Deleted deployment.\n")

    # Delete storage account
    storage_client.storage_accounts.delete(GROUP_NAME, STORAGE_ACCOUNT_NAME)
    print("Deleted storage account.\n")

    # Delete prerequisite resources
    prerequisites.delete()


if __name__ == "__main__":
    main()
