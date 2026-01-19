resource "azurerm_orchestrated_virtual_machine_scale_set" "vmss" {
    name = "day13-vmss"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    sku_name  = "Standard_B2s_v2"
    instances = 3
    platform_fault_domain_count = 1
    zones = ["1"]

    user_data_base64 = base64encode(file("user-data.sh"))



os_profile {
  linux_configuration {
    disable_password_authentication = true
    admin_username = "azureuser"
    admin_ssh_key {
        username   = "azureuser"
        public_key = file(".ssh/key.pub")
    }
  }
}
    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-gen2"
        version   = "latest"
    }
    os_disk {
        storage_account_type = "Premium_LRS"
        caching = "ReadWrite"
    }

    network_interface {
        name = "nic"
        primary = true
        enable_accelerated_networking = false

        ip_configuration {
            name  = "ipconfig"
            primary = true
            subnet_id = azurerm_subnet.subnet.id
            load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bap.id]
    
        }
    }

    boot_diagnostics {
        # storage_account_uri = ""
    }

    #Ignore changes to the instaces property, so that the vmss is not recreated when the number of instances changes
    lifecycle {
        ignore_changes = [
            instances
        ]
    }
}