resource "postgresql_role" "authentik" {
  name     = "authentik"
  login    = true
  password = var.postgresql_authentik_password
}