output "ip_address" {
  description = "IP address of NGINXaaS deployment."
  value       = azurerm_nginx_deployment.example.ip_address
}

output "post_logout_uri" {
  description = "Post logout URI configured in OIDC provider."
  value       = local.effective_post_logout_uri
}