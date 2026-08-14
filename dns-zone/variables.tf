variable "resource_group_name" {
  description = "Resource group where the shared private DNS zones are created."
  type        = string
}

variable "registration_enabled" {
  description = "Whether auto-registration of virtual machine DNS records is enabled for the virtual network link."
  type        = bool
  default     = false
}

variable "location" {
  description = "Azure region for the shared DNS resource group."
  type        = string
}

variable "private_dns_zones" {
  description = "Map of private DNS zone names keyed by purpose, for example storage_blob => privatelink.blob.core.windows.net."
  type        = map(string)
  default = {
    storage_blob = "privatelink.blob.core.windows.net"
    storage_queue = "privatelink.queue.core.windows.net"
    storage_table = "privatelink.table.core.windows.net"
    storage_file = "privatelink.file.core.windows.net"
    keyvault = "privatelink.vaultcore.azure.net"
  }
}

variable "approved_vnet_links" {
  description = "Map of approved virtual network IDs that should be linked to each private DNS zone."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags applied to the shared DNS zones and links."
  type        = map(string)
  default     = {}
}
