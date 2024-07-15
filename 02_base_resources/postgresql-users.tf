resource "postgresql_role" "authentik" {
  name     = data.onepassword_item.database_authentik.username
  login    = true
  password = data.onepassword_item.database_authentik.password

  depends_on = [kubectl_manifest.postgres_ingress]
}

resource "postgresql_role" "firefly" {
  name     = data.onepassword_item.database_firefly.username
  login    = true
  password = data.onepassword_item.database_firefly.password

  depends_on = [kubectl_manifest.postgres_ingress]
}

resource "postgresql_role" "mealie" {
  name     = data.onepassword_item.database_mealie.username
  login    = true
  password = data.onepassword_item.database_mealie.password

  depends_on = [kubectl_manifest.postgres_ingress]
}

resource "postgresql_role" "sonarr" {
  name     = data.onepassword_item.database_sonarr.username
  login    = true
  password = data.onepassword_item.database_sonarr.password

  depends_on = [kubectl_manifest.postgres_ingress]
}