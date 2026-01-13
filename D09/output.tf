#output "azurerm_storage_account_name" {
#  value = azurerm_storage_account.example.name
#}

output "rgname" {
    value = azurerm_resource_group.example.name
}

output "storage_account_names" {
  value = [for sa in azurerm_storage_account.example : sa.name]
}