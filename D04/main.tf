terraform {
  required_providers{
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 4.8.0"
    }

  }
  backend "azurerm" {
    resource_group_name = "tfsate-day04"
    storage_account_name = "day04923"
    container_name = "tfstate"
    key = "demo.terraform.tfstate"
  }
  
  required_version = ">= 1.9.0"
  
}

provider "azurerm" {
    features{
        
    }
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_storage_account" "example" {
  name                     = "tutorial12345"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}