terraform{
  backend "azurerm" {
    resource_group_name = "tfsate-day04"
    storage_account_name = "day04923"
    container_name = "tfstate"
    key = "demo.terraform.tfstate"
  }
  }