resource "postgresql_role" "authentik" {
  name     = data.onepassword_item.database_authentik.username
  login    = true
  password = data.onepassword_item.database_authentik.password

  depends_on = [time_sleep.wait_for_postgress, kubernetes_manifest.postgres_ingress]
}

resource "postgresql_role" "hass" {
  name     = var.postgresql_hass_username
  login    = true
  password = var.postgresql_hass_password

  depends_on = [time_sleep.wait_for_postgress, kubernetes_manifest.postgres_ingress]
}

resource "postgresql_role" "firefly" {
  name     = data.onepassword_item.database_firefly.username
  login    = true
  password = data.onepassword_item.database_firefly.password

  depends_on = [time_sleep.wait_for_postgress, kubernetes_manifest.postgres_ingress]
}