variable "location" {
  description = "Azure location name for NGINXaaS deployment."
  default     = "eastus2"
}

variable "name" {
  description = "Name of NGINXaaS deployment and related resources."
  default     = "example-nginx"
}

variable "sku" {
  description = "SKU of NGINXaaS deployment."
  default     = "publicpreview_Monthly_gmz7xq9ge3py"
}

variable "tags" {
  description = "Tags for NGINXaaS deployment and related resources."
  type        = map(any)
  default = {
    env = "Production"
  }
}
