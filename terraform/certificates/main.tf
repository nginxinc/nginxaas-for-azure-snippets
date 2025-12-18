terraform {
  required_version = "~> 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.97"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

data "azurerm_client_config" "current" {}

module "prerequisites" {
  source   = "../prerequisites"
  location = var.location
  name     = var.name
  tags     = var.tags
}

# This will give the current user admin permissions on the key vault
resource "azurerm_role_assignment" "current_user" {
  scope                = module.prerequisites.key_vault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_certificate" "example" {
  name         = var.name
  key_vault_id = module.prerequisites.key_vault_id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = false
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pem-file"
    }

    x509_certificate_properties {
      extended_key_usage = [
        "1.3.6.1.5.5.7.3.1",
        "1.3.6.1.5.5.7.3.2"
      ]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject            = "CN=example.com"
      validity_in_months = 12
    }
  }
  depends_on = [azurerm_role_assignment.current_user]
}

resource "azurerm_role_assignment" "example" {
  scope                = module.prerequisites.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.prerequisites.managed_identity_principal_id
}

resource "azurerm_nginx_deployment" "example" {
  name                     = var.name
  resource_group_name      = module.prerequisites.resource_group_name
  sku                      = var.sku
  capacity                 = 20
  location                 = var.location

  identity {
    type         = "UserAssigned"
    identity_ids = [module.prerequisites.managed_identity_id]
  }

  frontend_public {
    ip_address = [module.prerequisites.public_ipv4_address_id]
  }
  network_interface {
    subnet_id = module.prerequisites.subnet_id
  }

  tags = var.tags
}

resource "azurerm_nginx_certificate" "example" {
  name                     = var.name
  nginx_deployment_id      = azurerm_nginx_deployment.example.id
  key_virtual_path         = "/etc/nginx/ssl/test.key"
  certificate_virtual_path = "/etc/nginx/ssl/test.crt"
  key_vault_secret_id      = azurerm_key_vault_certificate.example.secret_id

  # - ensures deployment has role assignement to fetch certificate
  depends_on = [azurerm_role_assignment.example]
}

resource "azurerm_nginx_configuration" "example" {
  nginx_deployment_id = azurerm_nginx_deployment.example.id
  root_file           = "/etc/nginx/nginx.conf"

  config_file {
    content      = filebase64("${path.module}/nginx.conf")
    virtual_path = "/etc/nginx/nginx.conf"
  }

  config_file {
    content      = filebase64("${path.module}/api.conf")
    virtual_path = "/etc/nginx/site/api.conf"
  }

  depends_on = [
    azurerm_nginx_certificate.example
  ]
}
