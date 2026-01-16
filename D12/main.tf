variable "prefix" {
    default = "day-13"
}

data "azurerm_resource_group" "rg-shared" {
    name = "gitops-rg"
}

data "azurerm_virtual_network" "vnet-shared" {
    name                = "gitops-vm-vnet"
    resource_group_name = data.azurerm_resource_group.rg-shared.name
}

data "azurerm_subnet" "subnet-shared" {
    name                 = "default"
    virtual_network_name = data.azurerm_virtual_network.vnet-shared.name
    resource_group_name  = data.azurerm_resource_group.rg-shared.name
}
resource "azurerm_resource_group" "rg" {
    name     = "${var.prefix}-rg"
    location = data.azurerm_resource_group.rg-shared.location
}

resource "azurerm_network_interface" "main" {
    name                = "${var.prefix}-nic"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "internal"
        subnet_id                     = data.azurerm_subnet.subnet-shared.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_virtual_machine" "main" {
    name                  = "${var.prefix}-vm"
    location              = azurerm_resource_group.rg.location
    resource_group_name   = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.main.id]
    vm_size               = "Standard_B2s_v2"

    delete_os_disk_on_termination = true

    storage_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-gen2"
        version   = "latest"
    }

    storage_os_disk {
        name              = "${var.prefix}-osdisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    os_profile {
        computer_name  = "${var.prefix}-vm"
        admin_username = "azureuser"
        admin_password = "P@ssw0rd1234!"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

    tags = {
        environment = "demo"
        project     = "gitops"
    }
}
