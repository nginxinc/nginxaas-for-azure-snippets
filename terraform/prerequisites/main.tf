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
  address_space       = ["10.0.0.0/16"]

  tags = var.tags
}

resource "azurerm_subnet" "example" {
  name                 = var.name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
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

resource "azurerm_user_assigned_identity" "example" {
  location            = azurerm_resource_group.example.location
  name                = var.name
  resource_group_name = azurerm_resource_group.example.name

  tags = var.tags
}

data "azurerm_client_config" "current" {}

# This keyvault is NOT firewalled.
resource "azurerm_key_vault" "example" {
  name                      = var.name
  location                  = var.location
  resource_group_name       = azurerm_resource_group.example.name
  enable_rbac_authorization = true

  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  sku_name = "standard"

  tags = var.tags
}
