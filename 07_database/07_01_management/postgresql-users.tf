resource "kubernetes_secret" "pgpool_users" {
  metadata {
    name = var.pgpool_customUsersSecret
    namespace = "postgresql"
  }

  immutable = false

  data = {
    usernames = "postgres,${postgresql_role.authentik.name}"
    passwords = "${var.postgresql_admin_password},${var.postgresql_authentik_password}"
  }
}

resource "postgresql_role" "authentik" {
  name     = "authentik"
  login    = true
  password = var.postgresql_authentik_password
}