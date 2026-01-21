resource "azuread_group_member" "education_members" {
    for_each = {
      for k, v in local.users :
      k => v
      if v.group == "education-team"
    }

    group_object_id = azuread_group.education.object_id
    member_object_id = azuread_user.ad_users["${each.value.first_name}.${each.value.last_name}"].object_id
}

resource "azuread_group_member" "customer_success_members" {
    for_each = {
      for k, v in local.users :
      k => v
      if v.group == "customer-success"
    }
    group_object_id = azuread_group.customer_success.object_id
    member_object_id = azuread_user.ad_users["${each.value.first_name}.${each.value.last_name}"].object_id
}