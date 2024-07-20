resource "postgresql_database" "authentik" {
  name              = postgresql_role.authentik.name
  owner             = postgresql_role.authentik.name
  connection_limit  = -1
  allow_connections = true
}

resource "postgresql_database" "firefly" {
  name              = postgresql_role.firefly.name
  owner             = postgresql_role.firefly.name
  connection_limit  = -1
  allow_connections = true
}

resource "postgresql_database" "mealie" {
  name              = postgresql_role.mealie.name
  owner             = postgresql_role.mealie.name
  connection_limit  = -1
  allow_connections = true
}

resource "postgresql_database" "sonarr-main" {
  name              = "${postgresql_role.sonarr.name}-main"
  owner             = postgresql_role.sonarr.name
  connection_limit  = -1
  allow_connections = true
}

resource "postgresql_database" "sonarr-log" {
  name              = "${postgresql_role.sonarr.name}-log"
  owner             = postgresql_role.sonarr.name
  connection_limit  = -1
  allow_connections = true
}

resource "postgresql_database" "radarr-main" {
  name              = "${postgresql_role.radarr.name}-main"
  owner             = postgresql_role.radarr.name
  connection_limit  = -1
  allow_connections = true
}

resource "postgresql_database" "radarr-log" {
  name              = "${postgresql_role.radarr.name}-log"
  owner             = postgresql_role.radarr.name
  connection_limit  = -1
  allow_connections = true
}

resource "postgresql_database" "prowlarr-main" {
  name              = "${postgresql_role.prowlarr.name}-main"
  owner             = postgresql_role.prowlarr.name
  connection_limit  = -1
  allow_connections = true
}

resource "postgresql_database" "prowlarr-log" {
  name              = "${postgresql_role.prowlarr.name}-log"
  owner             = postgresql_role.prowlarr.name
  connection_limit  = -1
  allow_connections = true
}