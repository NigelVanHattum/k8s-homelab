### 1Password
data "onepassword_vault" "homelab_vault" {
  name = "Homelab"
}

### Azure tenant
data "onepassword_item" "azure_tenant_id" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = "Azure tenant"
}


### Generated passwords/ tokens
resource "random_password" "argocd_admin_password" {
  length           = 16
}


### ArgoCD
resource "kubernetes_secret" "argocd_secret" {
  metadata {
    name = "argocd-admin-password"
    namespace = kubernetes_namespace.argocd.metadata.0.name
  }

  data = {
    password =random_password.argocd_admin_password.result
  }
}

data "onepassword_item" "argocd_azure_credentials" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = "ArgoCD Azure Secret"
}

resource "onepassword_item" "argo_admin_password" {
  vault = data.onepassword_vault.homelab_vault.uuid

  title    = "ArgoCD admin login"
  category = "login"
  username = "admin"
  password = random_password.argocd_admin_password.result
}

### Traefik 
data "onepassword_item" "cloudflare_dns_token" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = "Cloudflare DNS token"
}

resource "kubernetes_secret" "cloudflare_api_token" {
  metadata {
    name = "cloudflare-token"
    namespace = kubernetes_namespace.traefik.metadata.0.name
  }

  immutable = true

  data = {
    "token" = data.onepassword_item.cloudflare_dns_token.password
  }
}


### PostgreSQL
data "onepassword_item" "database_postgresql" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = "Database-PostgreSQL"
}

data "onepassword_item" "database_authentik" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = "Database-Authentik"
}

data "onepassword_item" "database_firefly" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = "Database-Firefly"
}

resource "kubernetes_secret" "pgpool_users" {
  metadata {
    name = var.pgpool_customUsersSecret
    namespace = kubernetes_namespace.postgresql.metadata.0.name
  }

  immutable = false

  data = {
    usernames = "${data.onepassword_item.database_postgresql.username},${data.onepassword_item.database_authentik.username},${var.postgresql_hass_username},${data.onepassword_item.database_firefly.username}"
    passwords = "${data.onepassword_item.database_postgresql.password},${data.onepassword_item.database_authentik.password},${var.postgresql_hass_password},${data.onepassword_item.database_firefly.password}"
  }
}

resource "kubernetes_secret" "postgres_admin_password" {
  metadata {
    name = "postgres-admin-password"
    namespace = kubernetes_namespace.postgresql.metadata.0.name
  }

  immutable = true

  data = {
    repmgr-password = data.onepassword_item.database_postgresql.password
    password = data.onepassword_item.database_postgresql.password
  }
}


### InfluxDB
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

### Authentik
data "onepassword_item" "authentik_admin_token" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title    = "Authentik Token"
}

data "onepassword_item" "key_authentik" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = "Authentik Secret Key"
}

data "onepassword_item" "login_authentik" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = "Authentik admin login"
}

data "onepassword_item" "geoip_authentik" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = "Authentik GeoIP"
}

data "onepassword_item" "authentik_azure_credentials" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = "Authentik Azure Secret"
}

resource "kubernetes_secret" "authentik_initial_credentials" {
  metadata {
    name = "authentik-secret"
    namespace = kubernetes_namespace.authentik.metadata.0.name
  }

  immutable = true

  data = {
    token = data.onepassword_item.authentik_admin_token.password
    password = data.onepassword_item.login_authentik.password
    email = data.onepassword_item.login_authentik.username
  }
}