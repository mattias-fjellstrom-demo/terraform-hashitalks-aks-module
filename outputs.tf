output "fqdn" {
  value       = azurerm_kubernetes_cluster.this.fqdn
  description = "Fully qualified domain name (FQDN) of the cluster"
}

output "kube_config" {
  value       = azurerm_kubernetes_cluster.this.kube_config[0]
  description = "kube config for cluster authentication"
  sensitive   = true

  precondition {
    condition     = lookup(azurerm_kubernetes_cluster.this.kube_config[0], "host", null) != null
    error_message = "'host' missing in kube_config"
  }

  precondition {
    condition     = lookup(azurerm_kubernetes_cluster.this.kube_config[0], "client_certificate", null) != null
    error_message = "'client_certificate' missing in kube_config"
  }

  precondition {
    condition     = lookup(azurerm_kubernetes_cluster.this.kube_config[0], "client_key", null) != null
    error_message = "'client_key' missing in kube_config"
  }

  precondition {
    condition     = lookup(azurerm_kubernetes_cluster.this.kube_config[0], "cluster_ca_certificate", null) != null
    error_message = "'cluster_ca_certificate' missing in kube_config"
  }
}
