resource "azurerm_resource_group" "rg" {
  name     = "teraform-d17-rg"
  location = "Central India"
}

resource "azurerm_storage_account" "sa" {
    name = "day17sa"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    account_tier = "Standard"
    account_replication_type = "LRS"
}

resource "azurerm_service_plan" "example" {
    name = "example-app-service-plan"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    os_type = "Linux"
    sku_name = "B1"
}
resource "azurerm_linux_function_app" "example" {
    name = "example-linux-func-app"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    service_plan_id = azurerm_service_plan.example.id
    storage_account_name = azurerm_storage_account.sa.name
    storage_account_access_key = azurerm_storage_account.sa.primary_access_key

    site_config {
        application_stack {
            node_version = 18
        }
    }
}