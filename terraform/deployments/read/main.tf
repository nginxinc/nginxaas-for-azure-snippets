terraform {
  required_version = "~> 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.91"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_nginx_deployment" "example" {
  name                = var.name
  resource_group_name = var.name
}

data "azurerm_nginx_configuration" "example-default-conf" {
  nginx_deployment_id = data.azurerm_nginx_deployment.example.id
}

data "azurerm_nginx_certificate" "example" {
  name                = var.cert_name
  nginx_deployment_id = data.azurerm_nginx_deployment.example.id
}
