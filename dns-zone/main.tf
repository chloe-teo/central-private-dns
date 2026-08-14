module "resource_group" {
  source = "../../azure-modules/azure-resource-group"

  resource_group_name = var.resource_group_name
  location            = var.location
}

module "private_dns_zones" {
  source = "../../azure-modules/azure-private-dns-zone"

  for_each = var.private_dns_zones

  private_dns_zone_name = each.value
  resource_group_name   = module.resource_group.name
  tags                  = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = {
    for pair in flatten([
      for dns_key, dns_name in var.private_dns_zones : [
        for vnet_key, vnet_id in var.approved_vnet_links : {
          key     = "${dns_key}-${vnet_key}"
          dns_key = dns_key
          dns_name = dns_name
          vnet_id = vnet_id
          vnet_name = reverse(split("/", vnet_id))[0]
        }
      ]
    ]) : pair.key => pair
  }

  name                  = "${each.value.vnet_name}-link"
  resource_group_name   = module.resource_group.name
  private_dns_zone_name = each.value.dns_name
  virtual_network_id    = each.value.vnet_id
  registration_enabled  = var.registration_enabled
  tags                  = var.tags
}

