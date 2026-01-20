resource "azurerm_resource_group" "rg" {
    name = "day14-rg"
    location = "Central India"
}

resource "azurerm_virtual_network" "vnet1" {
    name = "day14-vnet1"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet1" {
    name = "day14-subnet1"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet1.name
    address_prefixes = ["10.0.0.0/24"]
}

resource "azurerm_virtual_network" "vnet2" {
    name = "day14-vnet2"
    address_space = ["10.1.0.0/16"]
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet2" {
    name = "day14-subnet2"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet2.name
    address_prefixes = ["10.1.0.0/24"]
}

resource "azurerm_virtual_network_peering" "vnet1-to-vnet2" {
    name = "vnet1-to-vnet2"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet1.name
    remote_virtual_network_id = azurerm_virtual_network.vnet2.id
    # allow_virtual_network_access = true
    # allow_forwarded_traffic = true
    # allow_gateway_transit = false
    # use_remote_gateways = false
}

resource "azurerm_virtual_network_peering" "vnet2-to-vnet1" {
    name = "vnet2-to-vnet1"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet2.name
    remote_virtual_network_id = azurerm_virtual_network.vnet1.id
    # allow_virtual_network_access = true
    # allow_forwarded_traffic = true
    # allow_gateway_transit = false
    # use_remote_gateways = false
}