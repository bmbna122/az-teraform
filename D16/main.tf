variable "prefix" {
    type = string
    default = "day-16"
}

resource "azurerm_resource_group" "rg" {
    name = "${var.prefix}-rg"
    location = "Central india"
} 

resource "azurerm_service_plan" "asp" {
    name = "${var.prefix}-asp"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    os_type = "Linux"
    sku_name = "S1"
}

resource "azurerm_linux_web_app" "app" {
    name = "${var.prefix}-app"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    service_plan_id = azurerm_service_plan.asp.id

    site_config {
        application_stack{
          node_version = "18-lts"
        }
    }
}

resource "azurerm_linux_web_app_slot" "slot" {
    name = "${var.prefix}-staging"
    app_service_id = azurerm_linux_web_app.app.id

    site_config {
       application_stack {
            node_version = "18-lts"
        }
    }
}
