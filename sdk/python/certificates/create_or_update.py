#! /usr/local/env python3

import os
import uuid

from azure.keyvault.certificates import (
    CertificateClient,
    CertificatePolicy,
)
from azure.identity import DefaultAzureCredential
from azure.mgmt.authorization import AuthorizationManagementClient
from azure.mgmt.msi import ManagedServiceIdentityClient
from azure.mgmt.keyvault import KeyVaultManagementClient
from azure.mgmt.nginx import NginxManagementClient


def main():
    TENANT_ID = os.environ.get("AZURE_TENANT_ID", None)
    SUBSCRIPTION_ID = os.environ.get("AZURE_SUBSCRIPTION_ID", None)
    GROUP_NAME = "myResourceGroup"
    LOCATION = "eastus"
    DEPLOYMENT_NAME = "myDeployment"
    VAULT_NAME = "myVault123456"
    KV_URL = "https://" + VAULT_NAME + ".vault.azure.net"
    CERTIFICATE_NAME = "myCert"
    MANAGED_IDENTITY_NAME = "myIdentity"
    CLIENT_ID = os.getenv("AZURE_CLIENT_ID")

    # Create clients
    # For other authentication approaches, please see: https://pypi.org/project/azure-identity/
    auth_client = AuthorizationManagementClient(
        credential=DefaultAzureCredential(), subscription_id=SUBSCRIPTION_ID
    )
    msi_client = ManagedServiceIdentityClient(
        credential=DefaultAzureCredential(), subscription_id=SUBSCRIPTION_ID
    )
    keyvault_client = KeyVaultManagementClient(
        credential=DefaultAzureCredential(), subscription_id=SUBSCRIPTION_ID
    )
    certificate_client = CertificateClient(
        credential=DefaultAzureCredential(),
        vault_url=KV_URL,
    )
    nginx_client = NginxManagementClient(
        credential=DefaultAzureCredential(),
        subscription_id=SUBSCRIPTION_ID,
    )

    # Fetch our identity
    identity = msi_client.user_assigned_identities.get(
        GROUP_NAME, MANAGED_IDENTITY_NAME
    )

    # Create vault
    # https://github.com/Azure-Samples/azure-samples-python-management/tree/main/samples/keyvault
    # A managed identity only requires the 'Key Vault Secrets User' role to give NGINXaaS for Azure
    # the appropriate permissions to pull certificates from AKV
    vault = keyvault_client.vaults.begin_create_or_update(
        GROUP_NAME,
        VAULT_NAME,
        {
            "location": LOCATION,
            "properties": {
                "tenant_id": TENANT_ID,
                "sku": {"family": "A", "name": "standard"},
                "access_policies": [],
                "enable_rbac_authorization": True,
                "enabled_for_deployment": True,
                "enabled_for_disk_encryption": True,
                "enabled_for_template_deployment": True,
            },
        },
    ).result()
    print("Created a vault:\n{}".format(vault))

    # Give current user key vault administrator role assignment
    # https://github.com/Azure-Samples/azure-samples-python-management/tree/main/samples/authorization
    # For a full list of Azure built-in roles see: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
    role_id = "00482a5a-887f-4fb3-b363-3b7fe8e74483"
    role_definition_id = "/".join(
        [
            "subscriptions",
            SUBSCRIPTION_ID,
            "providers/Microsoft.Authorization/roleDefinitions",
            role_id,
        ]
    )
    role_assignment = "88888888-7000-0000-0000-000000000004"  # arbitrary UUID
    auth_client.role_assignments.create(
        vault.id,
        role_assignment,
        {
            "role_definition_id": role_definition_id,
            "principal_id": CLIENT_ID,
            "principleType": "ServicePrincipal",
        },
    )
    print("Created a role assignment.\n")

    # Give identity key vault secrets user role assignment
    # https://github.com/Azure-Samples/azure-samples-python-management/tree/main/samples/authorization
    # For a full list of Azure built-in roles see: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
    role_id = "4633458b-17de-408a-b874-0445c86b69e6"
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
        vault.id,
        role_assignment,
        {
            "role_definition_id": role_definition_id,
            "principal_id": identity.principal_id,
        },
    )
    print("Created a role assignment.\n")

    # Create AKV certificate
    # https://learn.microsoft.com/en-us/azure/key-vault/certificates/quick-create-python
    certificate = certificate_client.begin_create_certificate(
        certificate_name=CERTIFICATE_NAME, policy=CertificatePolicy.get_default()
    ).result()
    print("Created a AKV certificate:\n{}".format(certificate))

    # Check that you have created your deployment already
    # For snippets to create a deployment navigate to ../deployments/create_or_update.py
    nginx_client.deployments.get(GROUP_NAME, DEPLOYMENT_NAME)

    # Create certificate in our deployment
    nginx_certificate = nginx_client.certificates.begin_create_or_update(
        GROUP_NAME,
        DEPLOYMENT_NAME,
        CERTIFICATE_NAME,
        {
            "properties": {
                "keyVirtualPath": "/etc/nginx/ssl/myCert.key",
                "certificateVirtualPath": "/etc/nginx/ssl/myCert.crt",
                "keyvaultSecretId": certificate.secret_id,
            },
        },
    ).result()
    print("Created a certificate:\n{}".format(nginx_certificate))

    # Get certificate
    nginx_certificate = nginx_client.certificates.get(
        GROUP_NAME, DEPLOYMENT_NAME, CERTIFICATE_NAME
    )
    print("Get certificate:\n{}".format(nginx_certificate))

    # Update certificate in our deployment
    nginx_certificate = nginx_client.certificates.begin_create_or_update(
        GROUP_NAME,
        DEPLOYMENT_NAME,
        CERTIFICATE_NAME,
        {
            "properties": {
                "keyVirtualPath": "/etc/nginx/ssl/myCertificate.key",
                "certificateVirtualPath": "/etc/nginx/ssl/myCertificate.crt",
                "keyvaultSecretId": certificate.secret_id,
            },
        },
    ).result()
    print("Updated a certificate:\n{}".format(certificate))

    # Delete our certificate from the deployment
    nginx_client.certificates.begin_delete(
        GROUP_NAME, DEPLOYMENT_NAME, CERTIFICATE_NAME
    )
    print("Deleted certificate\n")

    # Delete vault
    keyvault_client.vaults.delete(GROUP_NAME, VAULT_NAME)
    print("Deleted vault.\n")

    # Purge a deleted vault
    keyvault_client.vaults.begin_purge_deleted(VAULT_NAME, LOCATION).result()
    print("Purged deleted vault.\n")


if __name__ == "__main__":
    main()
