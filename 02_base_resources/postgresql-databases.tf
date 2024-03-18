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