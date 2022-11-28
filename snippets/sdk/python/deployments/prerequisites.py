#! /usr/local/env python3

import os

from azure.identity import DefaultAzureCredential
from azure.mgmt.authorization import AuthorizationManagementClient
from azure.mgmt.msi import ManagedServiceIdentityClient
from azure.mgmt.nginx import NginxManagementClient
from azure.mgmt.network import NetworkManagementClient
from azure.mgmt.resource import ResourceManagementClient

SUBSCRIPTION_ID = os.environ.get("AZURE_SUBSCRIPTION_ID", None)
GROUP_NAME = "myResourceGroup"
LOCATION = "eastus"
MANAGED_IDENTITY_NAME = "myIdentity"
PUBLIC_IP_ADDRESS_NAME = "myPublicIP"
NSG_NAME = "myNetworkSecurityGroup"
VIRTUAL_NETWORK_NAME = "myVirtualNetwork"
SUBNET_NAME = "mySubnet"

# Create clients
# For other authentication approaches, please see: https://pypi.org/project/azure-identity/
auth_client = AuthorizationManagementClient(
    credential=DefaultAzureCredential(), subscription_id=SUBSCRIPTION_ID
)
msi_client = ManagedServiceIdentityClient(
    credential=DefaultAzureCredential(), subscription_id=SUBSCRIPTION_ID
)
network_client = NetworkManagementClient(
    credential=DefaultAzureCredential(), subscription_id=SUBSCRIPTION_ID
)
nginx_client = NginxManagementClient(
    credential=DefaultAzureCredential(), subscription_id=SUBSCRIPTION_ID
)
resource_client = ResourceManagementClient(
    credential=DefaultAzureCredential(), subscription_id=SUBSCRIPTION_ID
)

# Create resources
# For additional snippets regarding creation of Azure resources you can refer to
# this repository: https://github.com/Azure-Samples/azure-samples-python-management
def create():
    """Create resources that are needed for NGINXaaS for Azure tutorials."""
    # Create resource group
    # https://github.com/Azure-Samples/azure-samples-python-management/tree/main/samples/resources
    resource_client.resource_groups.create_or_update(GROUP_NAME, {"location": LOCATION})
    print("Created a resource group.\n")

    # Create public ip address
    # https://github.com/Azure-Samples/azure-samples-python-management/tree/main/samples/network/ip
    public_ip = network_client.public_ip_addresses.begin_create_or_update(
        GROUP_NAME,
        PUBLIC_IP_ADDRESS_NAME,
        {
            "location": LOCATION,
            "public_ip_allocation_method": "Static",
            "sku": {"name": "Standard"},
        },
    ).result()
    print("Created a public IP.\n")

    # Create Network Security Group (NSG)

    # WARNING: This will open access to your virtual network to all the internet!
    # For full documentation on creating a security rules in NSGs see below:
    # https://learn.microsoft.com/en-us/azure/virtual-network/manage-network-security-group#create-a-security-rule
    nsg = network_client.network_security_groups.begin_create_or_update(
        GROUP_NAME,
        NSG_NAME,
        {
            "location": LOCATION,
            "security_rules": [
                {
                    "name": "allow_internet",
                    "priority": 1001,
                    "direction": "Inbound",
                    "access": "Allow",
                    "protocol": "*",
                    "source_port_range": "*",
                    "destination_port_range": "*",
                    "source_address_prefix": "Internet",
                    "destination_address_prefix": "*",
                }
            ],
        },
    ).result()
    print("Created a network security group.\n")

    # Create virtual network
    # https://github.com/Azure-Samples/azure-samples-python-management/tree/main/samples/network/virtual_network
    network_client.virtual_networks.begin_create_or_update(
        GROUP_NAME,
        VIRTUAL_NETWORK_NAME,
        {"address_space": {"address_prefixes": ["10.0.0.0/16"]}, "location": LOCATION},
    ).result()
    print("Created a virtual network.\n")

    # Create delegated subnet
    # https://github.com/Azure-Samples/azure-samples-python-management/tree/main/samples/network/virtual_network
    subnet = network_client.subnets.begin_create_or_update(
        GROUP_NAME,
        VIRTUAL_NETWORK_NAME,
        SUBNET_NAME,
        {
            "address_prefix": "10.0.1.0/24",
            "delegations": [
                {
                    "name": "nginx",
                    "service_name": "NGINX.NGINXPLUS/nginxDeployments",
                    "actions": [
                        "Microsoft.Network/virtualNetworks/subnets/join/action"
                    ],
                }
            ],
            "network_security_group": nsg,
        },
    ).result()
    print("Created a delegated subnet.\n")

    # Create user assigned managed identity
    identity = msi_client.user_assigned_identities.create_or_update(
        GROUP_NAME, MANAGED_IDENTITY_NAME, {"location": LOCATION}
    )
    print("Created a managed identity.\n")
    return subnet, public_ip, identity


def main():
    create()

    # Delete Group and all resources
    resource_client.resource_groups.begin_delete(GROUP_NAME).result()
    print("Deleted resource group.\n")


if __name__ == "__main__":
    main()
