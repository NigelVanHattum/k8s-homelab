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

resource "postgresql_role" "radarr" {
  name     = data.onepassword_item.database_radarr.username
  login    = true
  password = data.onepassword_item.database_radarr.password

  depends_on = [kubectl_manifest.postgres_ingress]
}

resource "postgresql_role" "prowlarr" {
  name     = data.onepassword_item.database_prowlarr.username
  login    = true
  password = data.onepassword_item.database_prowlarr.password

  depends_on = [kubectl_manifest.postgres_ingress]
}

resource "postgresql_role" "litellm" {
  name     = data.onepassword_item.database_litellm.username
  login    = true
  password = data.onepassword_item.database_litellm.password

  depends_on = [kubectl_manifest.postgres_ingress]
}