variable "environment" {
  type        = string
  description = "Deployment environment"
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Not an allowed environment, use 'dev' or 'prod'"
  }
}

variable "name_suffix" {
  type        = string
  description = "Name suffix for resource naming"
}

variable "azure_resource_group" {
  type = object({
    name     = string
    location = string
  })
  description = "Azure resource group for the AKS cluster"
}

variable "azure_virtual_network_subnet" {
  type = object({
    id = string
  })
  description = "Azure virtual network subnet for the AKS cluster"
}

variable "node_resource_group_name" {
  type        = string
  nullable    = true
  description = "AKS infrastructure resource group (for load balancer etc)"
}
