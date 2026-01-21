resource "azuread_group" "education" {
    display_name = "education-team"
    security_enabled = true
}

resource "azuread_group" "customer_success" {
    display_name = "customer-success"
    security_enabled = true
}