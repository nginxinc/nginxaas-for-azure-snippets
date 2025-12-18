terraform {
  required_version = "~> 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.29"
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
  web_application_firewall {
    activation_state_enabled = true
  }
  tags = var.tags
}

resource "azurerm_nginx_configuration" "example" {
  nginx_deployment_id = azurerm_nginx_deployment.example.id
  root_file           = "/etc/nginx/nginx.conf"

  config_file {
    content = base64encode(<<-EOT
user nginx;
worker_processes auto;
worker_rlimit_nofile 8192;
pid /run/nginx/nginx.pid;

load_module modules/ngx_http_app_protect_module.so;

events {
    worker_connections 4000;
}

error_log /var/log/nginx/error.log error;

http {
    app_protect_enforcer_address 127.0.0.1:50000;

    server {
        listen 80 default_server;

        location / {
            app_protect_enable on;
            app_protect_policy_file /etc/app_protect/conf/NginxDefaultPolicy.tgz;
            proxy_pass http://127.0.0.1:80/proxy/$request_uri;
        }

        location /proxy {
            default_type text/html;
            return 200 "Hello World\n";
        }
    }
}
EOT
    )
    virtual_path = "/etc/nginx/nginx.conf"
  }
}

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_nginx_deployment.example.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = module.prerequisites.managed_identity_principal_id
}
