locals {
    lb_allowd_ports = {
      http = 80
      https = 443
    }
}
resource "random_pet" "lb_hostname" {
    length = 2
    separator = "-"

}

# create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "day14-rg"
  location = "Central India"
}

# create a virtual network
resource "azurerm_virtual_network" "test" {
    name = "day14-vnet"
    address_space = ["11.0.0.0/16"]
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

# create a subnet within the virtual network
resource "azurerm_subnet" "subnet" {
    name = "subnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.test.name
    address_prefixes = ["11.0.0.0/20"]
}

# network security group for the subnet with a rule to allow http, https and ssh traffic "static block"
# resource "azurerm_network_security_group" "nsg" {
#     name = "day14-nsg"
#     location = azurerm_resource_group.rg.location
#     resource_group_name = azurerm_resource_group.rg.name

#     security_rule {
#         name = "allow-http"
#         priority = 100
#         direction = "Inbound"
#         access = "Allow"
#         protocol = "Tcp"
#         source_port_range = "*"
#         destination_port_range = "80"
#         source_address_prefix = "*"
#         destination_address_prefix = "*"
#         description = "Allow inbound HTTP traffic"
#     }

#     security_rule {
#         name = "allow-https"
#         priority = 101
#         direction = "Inbound"
#         access = "Allow"
#         protocol = "Tcp"
#         source_port_range = "*"
#         destination_port_range = "443"
#         source_address_prefix = "*"
#         destination_address_prefix = "*"
#         description = "Allow inbound HTTPS traffic"
#     }

#     security_rule {
#         name = "allow-ssh"
#         priority = 102
#         direction = "Inbound"
#         access = "Allow"
#         protocol = "Tcp"
#         source_port_range = "*"
#         destination_port_range = "22"
#         source_address_prefix = "*"
#         destination_address_prefix = "*"
#         description = "Allow inbound SSH traffic"
#     }
# }

# network security group for the subnet with a rule to allow http, https and ssh traffic "dynamic block"
resource "azurerm_network_security_group" "nsg" {
    name = "day14-nsg"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    dynamic "security_rule" {
        for_each = local.lb_allowd_ports
        content {
            name = "allow-${security_rule.key}"
            priority = 100 + index(keys(local.lb_allowd_ports), security_rule.key)
            direction = "Inbound"
            access = "Allow"
            protocol = "Tcp"
            source_port_range = "*"
            destination_port_range = security_rule.value
            source_address_prefix = "AzureLoadBalancer"
            destination_address_prefix = "*"
            description = "Allow inbound ${security_rule.key} traffic"
        }
    }

    # security_rule {
    #     name = "allow-ssh"
    #     priority = 200
    #     direction = "Inbound"
    #     access = "Allow"
    #     protocol = "Tcp"
    #     source_port_range = "*"
    #     destination_port_range = "22"
    #     source_address_prefix = "*"
    #     destination_address_prefix = "*"
    #     description = "Allow inbound SSH traffic"
    # }
    security_rule {
      name                       = "allow-azure-load-balancer"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
      description                = "Allow Azure Load Balancer health probes"
}
  security_rule {
    name                       = "allow-http-internet"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "Internet"
    source_port_range          = "*"
    destination_port_range     = "80"
    destination_address_prefix = "*"
  }

}

# associate nsg to subnet
resource "azurerm_subnet_network_security_group_association" "nsg"{
    subnet_id = azurerm_subnet.subnet.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

# A public IP address for the load balancer
resource "azurerm_public_ip" "lb_public_ip" {
    name = "day14-lb-pip"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method = "Static"
    sku = "Standard"
    zones = ["1", "2", "3"]
    domain_name_label = "${azurerm_resource_group.rg.name}-${random_pet.lb_hostname.id}"
}

# A load balancer with frontend IP configuration, backend address pool, #health probe and load balancing rule
resource "azurerm_lb" "lb" {
    name = "day14-lb"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku = "Standard"

    frontend_ip_configuration {
        name = "day14-frontend-config"
        public_ip_address_id = azurerm_public_ip.lb_public_ip.id
    }

    # backend_address_pool {
    #     name = "day14-backend-pool"
    # }

    # probe {
    #     name = "http-probe"
    #     protocol = "Http"
    #     port = 80
    #     request_path = "/"
    #     # interval_in_seconds = 15
    #     # number_of_probes = 2
    # }

    # load_balancing_rule {
    #     name = "http-rule"
    #     protocol = "Tcp"
    #     frontend_port = 80
    #     backend_port = 80
    #     frontend_ip_configuration_name = "day14-frontend-config"
    #     backend_address_pool_name = "day14-backend-pool"
    #     probe_name = "http-probe"
    #     enable_floating_ip = false
    #     idle_timeout_in_minutes = 4
    #     load_distribution = "Default"
    # }
}

# create a backend address pool for the load balancer
resource "azurerm_lb_backend_address_pool" "bap" {
    name = "day14-backend-pool"
    loadbalancer_id = azurerm_lb.lb.id
}

# set up loadbalancer probe to check if the backend is up
resource "azurerm_lb_probe" "http_probe" {
    name = "http-probe"
    loadbalancer_id = azurerm_lb.lb.id
    protocol = "Http"
    port = 80
    request_path = "/"
    # interval_in_seconds = 15
    # number_of_probes = 2
}

# set up load balance rule from azurerm_lb.lb frontend ip to azurerm_lb_backend_address_pool.bap backend ip port 80 to port 80
resource "azurerm_lb_rule" "http_rule" {
    name = "http-rule"
    loadbalancer_id = azurerm_lb.lb.id
    protocol = "Tcp"
    frontend_port = 80
    backend_port = 80
    frontend_ip_configuration_name = "day14-frontend-config"
    backend_address_pool_ids = [azurerm_lb_backend_address_pool.bap.id]
    probe_id = azurerm_lb_probe.http_probe.id
    # enable_floating_ip = false
    # idle_timeout_in_minutes = 4
    # load_distribution = "Default"
}

#add lb nat rules to allow ssh access to the backend instances
resource "azurerm_lb_nat_rule" "ssh_nat_rule" {
    name = "ssh-nat-rule"
    resource_group_name = azurerm_resource_group.rg.name
    loadbalancer_id = azurerm_lb.lb.id
    protocol = "Tcp"
    frontend_port_start = 50000
    frontend_port_end = 50100
    backend_port = 22
    frontend_ip_configuration_name = "day14-frontend-config"
    backend_address_pool_id = azurerm_lb_backend_address_pool.bap.id
}

# create a public ip for nat gateway
resource "azurerm_public_ip" "natgwpip" {
    name = "day14natgw-publicIP"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method = "Static"
    sku = "Standard"
    zones = ["1"]
}

#add nat gateway to enable outbound traffic from the backend instances
resource "azurerm_nat_gateway" "natgw" {
    name = "day14-nat-gateway"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku_name = "Standard"
    idle_timeout_in_minutes = 10
    zones = ["1"]
}

# add nat gateway to subnet
resource "azurerm_subnet_nat_gateway_association" "subnetnatgwassoc" {
    subnet_id = azurerm_subnet.subnet.id
    nat_gateway_id = azurerm_nat_gateway.natgw.id
}

# add nat gateway public ip association
resource "azurerm_nat_gateway_public_ip_association" "natgwpipassoc" {
    nat_gateway_id = azurerm_nat_gateway.natgw.id
    public_ip_address_id = azurerm_public_ip.natgwpip.id
}