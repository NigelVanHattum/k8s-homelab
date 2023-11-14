resource "postgresql_database" "authentik" {
  name              = postgresql_role.authentik.name
  owner             = postgresql_role.authentik.name
  connection_limit  = -1
  allow_connections = true
}