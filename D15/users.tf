data "azuread_domains" "all" {
    only_initial = true
}

locals{
    default_domain = data.azuread_domains.all.domains[0].domain_name
}

locals {
    users = csvdecode(file("users.csv"))
}

resource "azuread_user" "ad_users" {
    for_each = { for u in local.users : "${u.first_name}.${u.last_name}" => u }

    user_principal_name = "${lower(each.value.first_name)}.${lower(each.value.last_name)}@${local.default_domain}"
    display_name = "${each.value.first_name} ${each.value.last_name}"
    mail_nickname = lower(each.value.first_name)
    password = "welcome@123"
    force_password_change = true

    department = each.value.department
    job_title  = each.value.job_title
}