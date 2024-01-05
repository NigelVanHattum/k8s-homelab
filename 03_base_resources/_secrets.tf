resource "random_password" "argocd_admin_password" {
  length           = 16
}

resource "kubernetes_secret" "argocd_secret" {
  metadata {
    name = "argocd-admin-password"
    namespace = kubernetes_namespace.argocd.metadata.0.name
  }

  data = {
    password =random_password.argocd_admin_password.result
  }
}

resource "kubernetes_secret" "cloudflare_api_token" {
  metadata {
    name = "cloudflare-token"
    namespace = kubernetes_namespace.traefik.metadata.0.name
  }

  immutable = true

  data = {
    "token" = var.cloudlfare_dns_api_token
  }
}

resource "kubernetes_secret" "pgpool_users" {
  metadata {
    name = var.pgpool_customUsersSecret
    namespace = kubernetes_namespace.postgresql.metadata.0.name
  }

  immutable = false

  data = {
    usernames = "postgres,${var.postgresql_authentik_username},${var.postgresql_hass_username}"
    passwords = "${var.postgresql_admin_password},${var.postgresql_authentik_password},${var.postgresql_hass_password}"
  }
}

resource "kubernetes_secret" "postgres_admin_password" {
  metadata {
    name = "postgres-admin-password"
    namespace = kubernetes_namespace.postgresql.metadata.0.name
  }

  immutable = true

  data = {
    repmgr-password = var.postgresql_admin_password
    password = var.postgresql_admin_password
  }
}

resource "kubernetes_secret" "influxdb_admin" {
  metadata {
    name = var.influxdb_secret_name
    namespace = kubernetes_namespace.influxdb.metadata.0.name
  }

  immutable = false

  data = {
    admin-password = "${var.influxdb_admin_password}"
    admin-token = "${var.influxdb_admin_token}"
  }
}