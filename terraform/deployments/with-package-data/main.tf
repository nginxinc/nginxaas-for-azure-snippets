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
  features {}
}

module "prerequisites" {
  source   = "../../prerequisites"
  location = var.location
  name     = var.name
  tags     = var.tags
}

resource "azurerm_nginx_deployment" "example" {
  name                      = var.name
  resource_group_name       = module.prerequisites.resource_group_name
  sku                       = var.sku
  location                  = var.location
  capacity                  = 20
  automatic_upgrade_channel = "stable"
  diagnose_support_enabled  = true

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
/* 
# How to convert your config directory into package_data?

$ tree /tmp/etc/
/tmp/etc/
`-- nginx
    |-- conf.d
    |   `-- proxy.conf
    `-- nginx.conf

2 directories, 2 files

# Add a leading '/' while tarring etc/ directory under /tmp. Use gtar on macOS
$ cd /tmp/; tar cvzf example.tar.gz  --transform='s|^|/|' etc/
etc/
etc/nginx/
etc/nginx/conf.d/
etc/nginx/conf.d/proxy.conf
etc/nginx/nginx.conf

# Convert to base64; line wrap
$ base64 -i example.tar.gz -w 0
H4sIAAAAAAAAA+2WbWvbMBDH/dqf4soKhU...qmuwWACgAAA==

3 directories, 2 files
*/
  configuration {
    root_file    = "/etc/nginx/nginx.conf"
    package_data = "H4sIAAAAAAAAA+2WbWvbMBDH/dqf4soKhUH8/FCaUBjboHu1MArbYGA0W6m92JKR5TXpyHef5LaLk2bpBknK1vu9kPHpOJ30v5NtU5naxn5xFHEY6qcbh07/eY/hBpHnBr7ruJ7huK7vOwaEe86ro20kEQBG+7Vlst3i98j8P4qt9WdXBZvtrwr+Sv9Y6+8FkYv6H4Ke/ilnEyvbQxn8mf6+H8ZBGEe+0t+PQtT/IDzUvxZ8Nrf0y67W0AJHQfBb/b0gXtM/jJ3AAGdXCWzjmev/Ai7zogEtd3HVCiILzmBSlBSU9Zs6HCAM6IxUtTIRlkFF5sC4hGsupjDhAijLBm1DRQPXhcx5K6HiWTEp0i6WZXb1lDRUJjklGRVwwVXU41yNw4eTnwYfKCkH78ZwLGjFJU1IlonhUx/Tf0uv/7txp41/xyP3v/rbC9f6PwjiGPv/EOy//3Mpa/hhgqKtGykoqYDU9ybNDWe0M0XBdPjLWlLSyEQlxpY2tcx3dUm4juVYrhWcnaryuZ1dmGbPYRm7LBpJGZw660ESRioKL627vam6r3pr89vswe6F0mR0QtpSJnJeU5B0Ju1cVuVwxUdQ2QoGnuPAyejozfvXl5/Hb0H7nY9y7/yCliWHj1yU2dHIVoYv7GQZYLEhB3U0A3ctkYKlZZtR2Pb9Xk1rw1U71qbBK3Xy3RKb/GvSNKAlPLN1HqsuKlAp8yTNaTpd38LCXJhPXdwIgiAIgiAIgiAIgiAIgiAIgiDPkJ+qmuwWACgAAA=="
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_nginx_deployment.example.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = module.prerequisites.managed_identity_principal_id
}
