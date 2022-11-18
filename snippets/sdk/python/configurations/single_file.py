#! /usr/local/env python3

import base64
import os

from azure.identity import DefaultAzureCredential
from azure.mgmt.nginx import NginxManagementClient


def main():
    SUBSCRIPTION_ID = os.environ.get("AZURE_SUBSCRIPTION_ID", None)
    GROUP_NAME = "myResourceGroup"
    DEPLOYMENT_NAME = "myDeployment"
    CONFIGURATION_NAME = "default"  # configuration must be named default

    # Create clients
    # For other authentication approaches, please see: https://pypi.org/project/azure-identity/
    nginx_client = NginxManagementClient(
        credential=DefaultAzureCredential(),
        subscription_id=SUBSCRIPTION_ID,
    )

    # Check that you have created your deployment already
    # For snippets to create a deployment navigate to ../deployments/create_or_update.py
    nginx_client.deployments.get(GROUP_NAME, DEPLOYMENT_NAME)

    # Read in our configuration file
    filepath = os.path.join(os.path.dirname(__file__), "configs", "nginx.conf")
    file = open(filepath, "rb")
    content = file.read()
    b64_content = base64.b64encode(content).decode("ascii")

    # Create single file configuration in the deployment
    configuration = nginx_client.configurations.begin_create_or_update(
        GROUP_NAME,
        DEPLOYMENT_NAME,
        CONFIGURATION_NAME,
        {
            "properties": {
                "rootFile": "/etc/nginx/nginx.conf",
                "files": [
                    {
                        "content": b64_content,
                        "virtualPath": "/etc/nginx/nginx.conf",
                    }
                ],
            }
        },
    ).result()
    print("Created a configuration:\n{}".format(configuration))

    # Get configuration
    deployment = nginx_client.configurations.get(
        GROUP_NAME, DEPLOYMENT_NAME, CONFIGURATION_NAME
    )
    print("Get configuration:\n{}".format(deployment))

    # Delete our configuration from the deployment
    nginx_client.configurations.begin_delete(
        GROUP_NAME, DEPLOYMENT_NAME, CONFIGURATION_NAME
    ).result()
    print("Deleted configuration\n")


if __name__ == "__main__":
    main()
