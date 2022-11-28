#! /usr/local/env python3

import os

from azure.identity import DefaultAzureCredential
from azure.mgmt.authorization import AuthorizationManagementClient
from azure.mgmt.nginx import NginxManagementClient
from azure.mgmt.storage import StorageManagementClient

import prerequisites


def main():
    SUBSCRIPTION_ID = os.environ.get("AZURE_SUBSCRIPTION_ID", None)
    GROUP_NAME = "myResourceGroup"
    LOCATION = "eastus"
    DEPLOYMENT_NAME = "myDeployment"
    STORAGE_ACCOUNT_NAME = "mystorageaccount12345"
    BLOB_CONTAINER_NAME = "mylogcontainer"

    # Create clients
    # For other authentication approaches, please see: https://pypi.org/project/azure-identity/
    auth_client = AuthorizationManagementClient(
        credential=DefaultAzureCredential(), subscription_id=SUBSCRIPTION_ID
    )
    nginx_client = NginxManagementClient(
        credential=DefaultAzureCredential(), subscription_id=SUBSCRIPTION_ID
    )
    storage_client = StorageManagementClient(
        credential=DefaultAzureCredential(), subscription_id=SUBSCRIPTION_ID
    )

    # Create prerequisite resources
    subnet, public_ip, identity = prerequisites.create()

    # Create storage account
    # https://github.com/Azure-Samples/azure-samples-python-management/tree/main/samples/storage
    storage_client.storage_accounts.begin_create(
        GROUP_NAME,
        STORAGE_ACCOUNT_NAME,
        {
            "sku": {"name": "Standard_LRS"},
            "kind": "BlobStorage",
            "location": LOCATION,
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

    # Create blob container
    # https://github.com/Azure-Samples/azure-samples-python-management/tree/main/samples/storage
    storage_client.blob_containers.create(
        GROUP_NAME, STORAGE_ACCOUNT_NAME, BLOB_CONTAINER_NAME, {}
    )
    print("Created a blob container.\n")

    # Create deployment with a public IP
    deployment = nginx_client.deployments.begin_create_or_update(
        GROUP_NAME,
        DEPLOYMENT_NAME,
        {
            "sku": {"name": "preview_Monthly_gmz7xq9ge3py"},
            "tags": {"myKey": "myValue"},
            "location": LOCATION,
            "identity": {
                "type": "UserAssigned",
                "userAssignedIdentities": {identity.id: {}},
            },
            "properties": {
                "enableDiagnosticSupport": True,
                "networkProfile": {
                    "networkInterfaceConfiguration": {"subnetId": subnet.id},
                    "frontendIPConfiguration": {
                        "publicIPAddresses": [{"id": public_ip.id}]
                    },
                },
                "logging": {
                    "storageAccount": {
                        "accountName": STORAGE_ACCOUNT_NAME,
                        "containerName": BLOB_CONTAINER_NAME,
                    }
                },
            },
        },
    ).result()
    print("Created a deployment:\n{}".format(deployment))

    # Give identity blob contributor role assignment
    # https://github.com/Azure-Samples/azure-samples-python-management/tree/main/samples/authorization
    # For a full list of Azure built-in roles see: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
    role_id = "ba92f5b4-2d11-453d-a403-e96b0029c9fe"
    role_definition_id = "/".join(
        [
            "subscriptions",
            SUBSCRIPTION_ID,
            "providers/Microsoft.Authorization/roleDefinitions",
            role_id,
        ]
    )
    role_assignment = "88888888-7000-0000-0000-000000000003"  # arbitrary UUID
    auth_client.role_assignments.create(
        deployment.id,
        role_assignment,
        {
            "role_definition_id": role_definition_id,
            "principal_id": identity.principal_id,
        },
    )
    print("Created a role assignment.\n")

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
