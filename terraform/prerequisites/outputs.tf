output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.example.name
}

output "managed_identity_id" {
  description = "ID of the managed identity."
  value       = azurerm_user_assigned_identity.example.id
}

output "managed_identity_principal_id" {
  description = "Principal ID of the managed identity."
  value       = azurerm_user_assigned_identity.example.principal_id
}

output "public_ipv4_address_id" {
  description = "ID of public IPv4 address."
  value       = azurerm_public_ip.example.id
}

# Uncomment to manage the public IPv6 resource
# output "public_ipv6_address_id" {
#  description = "ID of public IPv6 address."
#  value       = azurerm_public_ip.ipv6_example.id
#}

output "subnet_id" {
  description = "ID of delegated subnet."
  value       = azurerm_subnet.example.id
}

output "key_vault_id" {
  description = "ID of Key Vault."
  value       = azurerm_key_vault.example.id
}
