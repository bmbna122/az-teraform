variable "environment" {
  type        = string
  description = "the env type"
  default     = "development"
}

variable "storage_disk" {
  type        = number
  description = "The storage disk size of OS"
  default     = 64
  }

variable "is_delete" {
  type        = bool
  description = "the default behavior of OS disk uopn VM termination"
  default     = true
}

variable "allowed_location" {
  type        = list(string)
  description = "The allowed location for resources"
  default     = ["East US", "Central India", "West Europe"]
}

variable "resource_tags" {
  type        = map(string)
  description = "tags to add to all resources"
  default     = {
    "environment" = "staging"
    "project"     = "terraform-azure"
    "managed_by"  = "terraform"
  }
}

variable "network_config" {
  type = tuple([string, string, number])
  description = "Network configuration (VNET address, subnet address, subnet prefix)"
  default = ["10.0.0.0/16", "10.0.2.0", 24]
}

#please don't change this from [0] beacuse of free tier limits
variable "allowed_vm_sizes" {
  type        = list(string)
  description = "Allowed VM sizes"
  default     = ["Standard_B2s_v2", "Standard_F2s_v2", "Standard_D2s_v3"]
}

variable "vm_config" {
  type = object({
    size         = string
    publisher   = string
    offer        = string
    sku          = string
    version     = string
  })
  description = "VM configuration "
  default = {
    size       = "Standard_B2s_v2"
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

variable "storage_account_name" {
  type        = set(string)
  default     = ["financestorageacct101", "financestorageacct102"]

}

variable "location" {
  type        = string
  description = "The location for all resources"
  default     = "Central India"
}