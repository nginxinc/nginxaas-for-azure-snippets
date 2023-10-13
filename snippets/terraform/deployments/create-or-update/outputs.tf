output "ip_address" {
  description = "IP address of NGINXaaS deployment."
  value       = jsondecode(azapi_resource.nginx.output).properties.ipAddress
}
