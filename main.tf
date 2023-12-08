locals {
  environment = {
    dev = {
      node_count = 1
      vm_size    = "Standard_D2_v2"
    }
    prod = {
      node_count = 3
      vm_size    = "Standard_D2_v2"
    }
  }

  node_count = local.environment[var.environment].node_count
  vm_size    = local.environment[var.environment].vm_size

  node_resource_group_name = var.node_resource_group_name == null ? "rg-azure-infra-${var.name_suffix}" : var.node_resource_group_name
}

resource "azurerm_kubernetes_cluster" "this" {
  name                 = "aks-${var.name_suffix}"
  resource_group_name  = var.azure_resource_group.name
  location             = var.azure_resource_group.location
  dns_prefix           = "aks${var.name_suffix}"
  node_resource_group  = local.node_resource_group_name
  azure_policy_enabled = true

  default_node_pool {
    name           = "default"
    node_count     = local.node_count
    vm_size        = local.vm_size
    vnet_subnet_id = var.azure_virtual_network_subnet.id
  }

  network_profile {
    network_policy      = "azure"
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    pod_cidr            = "192.168.0.0/16"
    service_cidr        = "172.16.128.0/13"
    dns_service_ip      = "172.16.128.10"
    outbound_type       = "loadBalancer"
  }

  identity {
    type = "SystemAssigned"
  }
}
