#! /usr/local/env python3

import os

from azure.identity import DefaultAzureCredential
from azure.mgmt.nginx import NginxManagementClient

import prerequisites


def main():
    SUBSCRIPTION_ID = os.environ.get("AZURE_SUBSCRIPTION_ID", None)
    GROUP_NAME = "myResourceGroup"
    LOCATION = "eastus"
    DEPLOYMENT_NAME = "myDeployment"

    # Create clients
    # For other authentication approaches, please see: https://pypi.org/project/azure-identity/
    nginx_client = NginxManagementClient(
        credential=DefaultAzureCredential(), subscription_id=SUBSCRIPTION_ID
    )
    # Create prerequisite resources
    subnet, public_ip, identity = prerequisites.create()

    # - public IP configuration example
    network_profile_public = {
        "networkInterfaceConfiguration": {"subnetId": subnet.id},
        "frontendIPConfiguration": {"publicIPAddresses": [{"id": public_ip.id}]},
    }

    # Create deployment with a public IP
    deployment = nginx_client.deployments.begin_create_or_update(
        GROUP_NAME,
        DEPLOYMENT_NAME,
        {
            "sku": {"name": "standard_Monthly"},
            "tags": {"myKey": "myValue"},
            "location": LOCATION,
            "identity": {
                "type": "UserAssigned",
                "userAssignedIdentities": {identity.id: {}},
            },
            "properties": {
                "enableDiagnosticSupport": False,
                "networkProfile": network_profile_public,
                "scalingProperties": {
                    "capacity": 20
                },
                "userProfile": {
                    "preferredEmail": "user@f5.com"
                }
            },
        },
    ).result()
    print("Created a deployment:\n{}".format(deployment))

    # Get deployment
    deployment = nginx_client.deployments.get(GROUP_NAME, DEPLOYMENT_NAME)
    print("Get deployment:\n{}".format(deployment))

    # Update deployment with a new tag and enable metrics
    deployment = nginx_client.deployments.begin_update(
        GROUP_NAME,
        DEPLOYMENT_NAME,
        {
            "sku": {"name": "standard_Monthly"},
            "tags": {"myNewTag": "myNewValue"},
            "location": LOCATION,
            "properties": {
                "enableDiagnosticSupport": True,
            },
        },
    ).result()
    print("Updated deployment:\n{}".format(deployment))

    #  Delete a deployment
    nginx_client.deployments.begin_delete(GROUP_NAME, DEPLOYMENT_NAME).result()
    print("Deleted deployment.\n")

    # Delete prerequisite resources
    prerequisites.delete()


if __name__ == "__main__":
    main()
