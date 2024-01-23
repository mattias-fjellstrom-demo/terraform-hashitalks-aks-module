data "azurerm_resource_group" "dns" {
  name = "dns"
}

data "azurerm_dns_zone" "mattiasfjellstromcom" {
  name                = "mattiasfjellstrom.com"
  resource_group_name = data.azurerm_resource_group.dns.name
}

resource "azurerm_role_assignment" "dns" {
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_kubernetes_cluster.this.web_app_routing[0].web_app_routing_identity[0].object_id
  scope                = data.azurerm_resource_group.dns.id
}
