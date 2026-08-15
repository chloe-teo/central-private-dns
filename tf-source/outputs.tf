output "private_dns_zone_ids" {
  description = "The approved shared private DNS zone IDs created by the network team."
  value = {
    for key, zone in module.private_dns_zones : key => zone.private_dns_zone_id
  }
}

output "private_dns_zone_names" {
  description = "The private DNS zone names created by the network team."
  value = {
    for key, zone in module.private_dns_zones : key => zone.private_dns_zone_name
  }
}

output "approved_vnet_links" {
  description = "The approved VNet IDs to link to the shared private DNS zones."
  value       = var.approved_vnet_links
}
