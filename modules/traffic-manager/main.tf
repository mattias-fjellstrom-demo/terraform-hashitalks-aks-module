terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

variable "endpoint01" {
  type = string
}

resource "random_id" "server" {
  keepers = {
    azi_id = 1
  }

  byte_length = 8
}

resource "azurerm_resource_group" "this" {
  name     = "rg-traffic-manager"
  location = "swedencentral"
}

resource "azurerm_traffic_manager_profile" "this" {
  resource_group_name = azurerm_resource_group.this.location
  name                = ""
  dns_config {
    relative_name = random_id.server.hex
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }

  traffic_routing_method = "Weighted"
}

resource "azurerm_traffic_manager_external_endpoint" "this" {
  name       = "aks-01"
  profile_id = azurerm_traffic_manager_profile.this.id
  weight     = 100
  target     = var.endpoint01
}
