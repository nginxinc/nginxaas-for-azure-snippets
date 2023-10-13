terraform {
  required_version = "~> 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.57"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {

}

module "prerequisites" {
  source   = "../../prerequisites"
  location = var.location
  name     = var.name
  tags     = var.tags
}

# - this relies on making a raw API request, this body we send can be best found at the below URI 
# https://github.com/Azure/azure-rest-api-specs/blob/5797d78f04cd8ca773be82d2c99a3294009b3f0a/specification/nginx/resource-manager/NGINX.NGINXPLUS/stable/2023-04-01/swagger.json#L1240
# - for more info on azapi_resource see the below URI
# https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/azapi_resource
resource "azapi_resource" "nginx" {
  type                      = "Nginx.NginxPlus/nginxDeployments@2023-04-01"
  name                      = var.name
  parent_id                 = module.prerequisites.resource_group_id
  location                  = var.location
  schema_validation_enabled = false

  identity {
    type         = "UserAssigned"
    identity_ids = [module.prerequisites.managed_identity_id]
  }

  body = jsonencode({
    sku = {
      name = var.sku
    }
    properties = {
      networkProfile = {
        frontEndIPConfiguration = {
          publicIPAddresses = [
            { id = module.prerequisites.public_ip_address_id }
          ]
        }
        networkInterfaceConfiguration = {
          subnetId = module.prerequisites.subnet_id
        }
      }
      scalingProperties = {
        capacity = 10
      }
    }

  })

  tags                   = var.tags
  response_export_values = ["properties.ipAddress"]
}

resource "azurerm_role_assignment" "example" {
  scope                = azapi_resource.nginx.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = module.prerequisites.managed_identity_principal_id
}
