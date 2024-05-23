variable "location" {
  description = "Azure location name for NGINXaaS deployment."
  default     = "eastus2"
}

variable "name" {
  description = "Name of NGINXaaS deployment and related resources."
  default     = "example-nginx"
}

variable "storage_account_name" {
  description = "Name of the storage account to store NGINX logs."
  default     = "examplenginxstorageacct"
}

variable "sku" {
  description = "SKU of NGINXaaS deployment."
  default     = "standard_Monthly"
}

variable "tags" {
  description = "Tags for NGINXaaS deployment and related resources."
  type        = map(any)
  default = {
    env = "Production"
  }
}
