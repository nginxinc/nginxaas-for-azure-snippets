variable "location" {
  description = "Azure location name for NGINXaaS deployment."
  default     = "eastus"
}

variable "name" {
  description = "Name of NGINXaaS deployment and related resources."
  default     = "example-nginx"
}

variable "sku" {
  description = "SKU of NGINXaaS deployment."
  default     = "standardv2_Monthly"
}

variable "tags" {
  description = "Tags for NGINXaaS deployment and related resources."
  type        = map(any)
  default = {
    env = "Production"
  }
}

variable "automatic_upgrade_channel" {
  description = "Automatic upgrade channel for NGINXaaS deployment."
  type        = string
  default     = "preview"
}

variable "issuer" {
  description = "OIDC issuer URL"
  type        = string
}

variable "client_id" {
  description = "OIDC client ID"
  type        = string
}

variable "client_secret" {
  description = "OIDC client secret"
  type        = string
  sensitive   = true
}

variable "resolver" {
  description = "OIDC resolver"
  type        = string
}