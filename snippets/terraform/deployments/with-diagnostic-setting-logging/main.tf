terraform {
  required_version = "~> 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85"
    }
  }
}

provider "azurerm" {
  features {}
}

module "prerequisites" {
  source   = "../../prerequisites"
  location = var.location
  name     = var.name
  tags     = var.tags
}

data "azurerm_storage_account" "example" {
  name                = var.storage_account_name
  resource_group_name = var.storage_account_resource_group
}

resource "azurerm_nginx_deployment" "example" {
  name                     = var.name
  resource_group_name      = module.prerequisites.resource_group_name
  sku                      = var.sku
  location                 = var.location
  capacity                 = 20
  diagnose_support_enabled = false # This enables metrics to azure monitoring, not nginx logs

  # Required for diagnostic setting logging
  identity {
    type = "SystemAssigned"
  }

  frontend_public {
    ip_address = [module.prerequisites.public_ip_address_id]
  }
  network_interface {
    subnet_id = module.prerequisites.subnet_id
  }

  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "example" {
  name               = "${azurerm_nginx_deployment.example.name}-logs"
  target_resource_id = azurerm_nginx_deployment.example.id
  storage_account_id = data.azurerm_storage_account.example.id

  enabled_log {
    category = "NginxLogs"
  }
}
