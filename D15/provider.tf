terraform {
    required_providers {
        azuread = {
            source = "hashicorp/azuread"
            version = "~> 2.45"
        }
    }
}

provider "azuread" {
    client_id = var.client_id
    client_secret = var.client_secret
    tenant_id = var.tenant_id
}