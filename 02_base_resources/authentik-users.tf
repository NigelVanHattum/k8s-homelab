## Default admin user
data "authentik_user" "akadmin" {
  username = "akadmin"
}

data "authentik_user" "nigel" {
  username = "Nigel"
}

data "authentik_user" "elina" {
  username = "Elina"
}

resource "authentik_group" "admin" {
  name         = local.authentik.group_admin
  users        = [data.authentik_user.akadmin.id, data.authentik_user.nigel.id]
  is_superuser = false
}

resource "authentik_group" "household" {
  name         = local.authentik.group_household
  users        = [data.authentik_user.akadmin.id, data.authentik_user.nigel.id, data.authentik_user.elina.id]
  is_superuser = false
}

resource "authentik_group" "guests" {
  name         = local.authentik.group_guests
  users        = [data.authentik_user.akadmin.id, data.authentik_user.nigel.id]
  is_superuser = false
}
