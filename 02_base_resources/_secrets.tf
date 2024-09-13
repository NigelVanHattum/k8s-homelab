data "terraform_remote_state" "infra" {
  backend = "remote"
  config = {
    organization = "Nigel_dev"
    workspaces = {
      name = "01_infra"
    }
  }
}

### 1Password
data "onepassword_vault" "homelab_vault" {
  name = local.onepassword.vault_name
}

### Azure tenant
data "onepassword_item" "azure_tenant_id" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = local.onepassword.azure_tenant
}


### Generated passwords/ tokens
resource "random_password" "argocd_admin_password" {
  length           = 16
}


### ArgoCD
data "onepassword_item" "argocd_azure_credentials" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = local.onepassword.argo.azure_secret
}

resource "onepassword_item" "argo_admin_password" {
  vault = data.onepassword_vault.homelab_vault.uuid

  title    = local.onepassword.argo.admin
  category = "login"
  username = "admin"
  password = random_password.argocd_admin_password.result
}

### Grafana
data "onepassword_item" "grafana_token" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = local.onepassword.grafana.api_token
}

### Traefik 
data "onepassword_item" "cloudflare_dns_token" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = local.onepassword.traefik.cloudflare_api_token
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
data "onepassword_item" "synology_c2" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = local.onepassword.postgresql.synology_c2
}

data "onepassword_item" "database_postgresql" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = local.onepassword.postgresql.postgres_user
}

resource "kubernetes_secret" "postgres_admin" {
  metadata {
    name = "postgresql-superuser"
    namespace = kubernetes_namespace.postgresql.metadata.0.name
    labels = {
      "cnpg.io/reload" = ""
    }
  }

  data = {
    username = data.onepassword_item.database_postgresql.username
    password = data.onepassword_item.database_postgresql.password
    host     = local.database.read_write_service_name
  }

  type = "kubernetes.io/basic-auth"
}

data "onepassword_item" "database_authentik" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = local.onepassword.postgresql.authentik_user
}

data "onepassword_item" "database_firefly" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = local.onepassword.postgresql.firefly_user
}

data "onepassword_item" "database_mealie" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = local.onepassword.postgresql.mealie_user
}

data "onepassword_item" "database_sonarr" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = local.onepassword.postgresql.sonarr
}

data "onepassword_item" "database_radarr" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = local.onepassword.postgresql.radarr
}

data "onepassword_item" "database_prowlarr" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = local.onepassword.postgresql.prowlarr
}

### InfluxDB
data "onepassword_item" "influxdb_admin_user" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = local.onepassword.postgresql.radarr
}

data "onepassword_item" "influxdb_token" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = local.onepassword.postgresql.prowlarr
}

resource "kubernetes_secret" "influxdb_admin" {
  metadata {
    name = var.influxdb_secret_name
    namespace = kubernetes_namespace.influxdb.metadata.0.name
  }

  immutable = false

  data = {
    username = "${data.onepassword_item.influxdb_admin_user.username}"
    admin-password = "${data.onepassword_item.influxdb_admin_user.password}"
    admin-token = "${data.onepassword_item.influxdb_token.password}"
  }
}

### Authentik
data "onepassword_item" "authentik_admin_token" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title    = local.onepassword.authentik.api_token
}

data "onepassword_item" "key_authentik" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = local.onepassword.authentik.secret_key
}

data "onepassword_item" "login_authentik" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = local.onepassword.authentik.admin_credentials
}

data "onepassword_item" "geoip_authentik" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = local.onepassword.authentik.geo_ip
}

data "onepassword_item" "authentik_azure_credentials" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = local.onepassword.authentik.azure_secret
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

resource "kubernetes_secret" "authentik_geo_ip_credentials" {
  metadata {
    name = "authentik-geoip-secret"
    namespace = kubernetes_namespace.authentik.metadata.0.name
  }

  immutable = true

  data = {
    account_id = data.onepassword_item.geoip_authentik.username
    license_key = data.onepassword_item.geoip_authentik.password
  }
}