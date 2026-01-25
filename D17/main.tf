resource "azurerm_resource_group" "rg" {
  name     = "teraform-d17-rg"
  location = "Central India"
}

data "azurerm_storage_account" "shared" {
    name = "k8spracticestorage"
    resource_group_name = "k8s-practice-rg"
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
    storage_account_name = data.azurerm_storage_account.shared.name
    storage_account_access_key = data.azurerm_storage_account.shared.primary_access_key

    site_config {
        application_stack {
            node_version = 18
        }
    }
}