resource "azurerm_resource_group" "example" {
  name     = "${var.environment}-resources"
  location = var.location
  tags = {
    envvironment = var.environment
  }
    lifecycle {
      create_before_destroy = true
      ignore_changes = [tags]
    
  }
}

resource "azurerm_storage_account" "example" {
  for_each = var.storage_account_name
  name                     = each.value
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = var.resource_tags["environment"]
  }
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    #ignore_changes = [ account_replication_type]
    precondition {
      condition     = contains(var.allowed_location, var.location)
      error_message = "The location ${var.location} is not allowed."
    }
  }
}