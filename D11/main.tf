locals {
    formatted_name = lower(replace(var.project_name, " ", "_"))
    merged_tags    = merge(var.default_tags, var.environment_tags)
    storage_formated = replace(replace(lower(substr(var.storage_account_name,0,23))," ",""),"!","")
    formated_ports = split(",",(var.allowed_ports))
  nsg_rules = {
    for idx, port in local.formated_ports :
    "port-${port}" => {
        name = "port-${port}"
      priority = 100 + idx
      destination_port_range = port
      description = "Allow inbound traffic on port: ${port}"
    }
    #vm_size = lookup(var.environments, var.environment, null).instance_size
}
    vm_size = lookup(var.vm_sizes,var.environment, lower("dev"))

    user_location = ["eastus", "westus", "centraus", "eastus"]
    default_location = ["centralindia"]

    unique_location = toset(concat(local.user_location, local.default_location))

    monthly_costs = [-50, 100, 75, 200]
    positive_costs = [for cost in local.monthly_costs : abs(cost)]
    max_cost = max(local.positive_costs...)
}

resource azurerm_resource_group rg {
  name     = "${local.formatted_name}-rg"
  location = "Central India"
  tags = local.merged_tags
}

resource "azurerm_storage_account" "example" {
  name                     = local.storage_formated
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

    tags = local.merged_tags

}

resource "azurerm_network_security_group" "example" {
    name = "${local.formatted_name}-nsg"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    lifecycle {
        create_before_destroy = true
    }

    # Here's where we need the dynamic block
    dynamic "security_rule" {
        for_each = local.nsg_rules
        content{
            name = security_rule.key
            priority = security_rule.value.priority
            direction = "Inbound"
            access = "Allow"
            protocol = "Tcp"
            source_port_range = "*"
            destination_port_range = security_rule.value.destination_port_range
            source_address_prefix = "*"
            destination_address_prefix = "*"
            description = security_rule.value.description
        }
    }

}
output "resource_group_name" {
    value = azurerm_resource_group.rg.name
}

output "storage_account_name" {
    value = azurerm_storage_account.example.name
}

output "nsg_rules"{
    value = local.nsg_rules
}

output "security_name"{
    value = azurerm_network_security_group.example.name
}

output "vm_size" {
    value = local.vm_size
}

output "backup_file"{
    value = var.backup
}
output "credential" {
    value = var.credentials
    sensitive = true
}

output "unique_locations" {
    value = local.unique_location
}

output "max_monthly_cost" {
    value = local.max_cost
}

output "positive_costs" {
    value = local.positive_costs
}