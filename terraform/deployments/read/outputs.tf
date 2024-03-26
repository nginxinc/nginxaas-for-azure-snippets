output "ip_address" {
  description = "IP address of NGINXaaS deployment."
  value       = data.azurerm_nginx_deployment.example.ip_address
}

output "capacity" {
  description = "NCU capacity of NGINXaaS deployment."
  value       = data.azurerm_nginx_deployment.example.capacity
}

output "nginx_version" {
  description = "NGINX version of the deployment."
  value       = data.azurerm_nginx_deployment.example.nginx_version
}

output "sku" {
  description = "SKU of the deployment."
  value       = data.azurerm_nginx_deployment.example.sku
}

output "nginx_conf_content" {
  description = "NGINX conf for the deployment."
  value       = [for i in data.azurerm_nginx_configuration.example-default-conf.config_file.* : base64decode(i.content ) if i.virtual_path == data.azurerm_nginx_configuration.example-default-conf.root_file ][0]
}

output "cert_virtual_path" {
  description = "Virtual path of a cert for the deployment."
  value = data.azurerm_nginx_certificate.example.certificate_virtual_path
}

output "key_virtual_path" {
  description = "Virtual path of a key for the deployment."
  value = data.azurerm_nginx_certificate.example.key_virtual_path
}