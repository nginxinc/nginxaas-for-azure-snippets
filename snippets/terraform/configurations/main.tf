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
  features {}
}

module "prerequisites" {
  source   = "../prerequisites"
  location = var.location
  name     = var.name
  tags     = var.tags
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
}
