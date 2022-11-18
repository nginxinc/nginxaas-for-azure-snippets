terraform {
  required_version = "~> 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.20"
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

# This keyvault is NOT firewalled.
resource "azurerm_key_vault" "example" {
  name                      = var.name
  location                  = var.location
  resource_group_name       = module.prerequisites.resource_group_name
  enable_rbac_authorization = true

  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  sku_name = "standard"

  tags = var.tags
}

resource "azurerm_key_vault_certificate" "example" {
  name         = var.name
  key_vault_id = azurerm_key_vault.example.id

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
}

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.prerequisites.managed_identity_principal_id
}

resource "azurerm_nginx_deployment" "example" {
  name                     = var.name
  resource_group_name      = module.prerequisites.resource_group_name
  sku                      = var.sku
  location                 = var.location
  managed_resource_group   = "example"
  diagnose_support_enabled = false

  identity {
    type         = "UserAssigned"
    identity_ids = [module.prerequisites.managed_identity_id]
  }

  frontend_public {
    ip_address = [module.prerequisites.public_ip_address_id]
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
