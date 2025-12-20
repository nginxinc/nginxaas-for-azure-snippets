terraform {
  required_version = "~> 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  # Add your subscription ID here.
  subscription_id = ""
  features {}
}

# VARIABLES
variable "location" {
  description = "Azure location name for NGINXaaS deployment."
  default     = "eastus"
}

variable "name" {
  description = "Name of NGINXaaS deployment and related resources."
  default     = "example-dev"
}

variable "sku" {
  description = "SKU of NGINXaaS deployment."
  default     = "standardv2_Monthly"
}

variable "tags" {
  description = "Tags for NGINXaaS deployment and related resources."
  type        = map(any)
  default = {
    env = "dev"
  }
}

# Azure Resources
resource "azurerm_resource_group" "example" {
  name     = var.name
  location = var.location

  tags = var.tags
}

resource "azurerm_public_ip" "example" {
  name                = var.name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_virtual_network" "example" {
  name                = var.name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/27"]

  tags = var.tags
}

resource "azurerm_subnet" "example" {
  name                 = var.name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/27"]

  delegation {
    name = "nginx"
    service_delegation {
      name = "NGINX.NGINXPLUS/nginxDeployments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

# WARNING: This opens up the NSG to allow traffic to deployment from anywhere.
resource "azurerm_network_security_group" "example" {
  name                = var.name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = var.name
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_nginx_deployment" "example" {
  name                      = var.name
  resource_group_name       = azurerm_resource_group.example.name
  sku                       = var.sku
  location                  = var.location
  capacity                  = 20
  automatic_upgrade_channel = "stable"
  diagnose_support_enabled  = true

  identity {
    type = "SystemAssigned"
  }

  frontend_public {
    ip_address = [azurerm_public_ip.example.id]
  }
  network_interface {
    subnet_id = azurerm_subnet.example.id
  }

  tags = var.tags
}

resource "azurerm_nginx_configuration" "example-config" {
  nginx_deployment_id = azurerm_nginx_deployment.example.id
  root_file           = "/etc/nginx/nginx.conf"

  config_file {
    content = base64encode(<<-EOT
user nginx;
worker_processes auto;
worker_rlimit_nofile 8192;
pid /run/nginx/nginx.pid;

events {
    worker_connections 4000;
}

error_log /var/log/nginx/error.log error;

http {
    server {
        listen 80 default_server;
        server_name localhost;
        location / {
            return 200 'Hello World';
        }
    }
}
EOT
    )
    virtual_path = "/etc/nginx/nginx.conf"
  }
}

# OUTPUTS

output "ip_address" {
  description = "IP address of NGINXaaS deployment."
  value       = azurerm_nginx_deployment.example.ip_address
}
