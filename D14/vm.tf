resource "azurerm_network_interface" "nic1" {
    name = "day14-nic1"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.subnet1.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_virtual_machine" "vm1" {
    name = "day14-vm1"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.nic1.id]
    vm_size = "Standard_B2s_v2"

    delete_os_disk_on_termination = true

    storage_image_reference {
        publisher = "Canonical"
        offer = "0001-com-ubuntu-server-jammy"
        sku = "22_04-lts-gen2"
        version = "latest"
    }

    storage_os_disk {
        name = "day14-os-disk1"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    os_profile {
        computer_name = "day14vm1"
        admin_username = "azureuser"
        admin_password = "Password1234!"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }
}

resource "azurerm_network_interface" "nic2" {
    name = "day14-nice2"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_configuration {
        name = "interanal"
        subnet_id = azurerm_subnet.subnet2.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_virtual_machine" "vm2" {
    name = "day14-vm2"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.nic2.id]
    vm_size = "standard_B2s_v2"
    delete_os_disk_on_termination = true

    storage_image_reference {
        publisher = "canonical"
        offer = "0001-com-ubuntu-server-jammy"
        sku = "22_04-lts-gen2"
        version = "latest"
    }
    storage_os_disk {
        name = "day14-os-disk2"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name = "day14vm2"
        admin_username = "azureuser"
        admin_password = "Password1234!" 
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
}
