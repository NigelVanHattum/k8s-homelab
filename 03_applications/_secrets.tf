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
  name = "Homelab"
}

### Authentik
data "authentik_flow" "default_authorization_flow" {
  slug = "default-provider-authorization-implicit-consent"
}

### PostgreSQL
data "onepassword_item" "database_firefly" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = "postgresql-Firefly"
}

### ArgoCD
data "onepassword_item" "argo_admin" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title    = "ArgoCD admin login"
}

### Authentik
data "onepassword_item" "authentik_admin_token" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title    = "Authentik Token"
}


### Firefly
data "onepassword_item" "firefly_app_key" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = "Firefly App Key"
}

data "onepassword_item" "firefly_cron_token" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = "Firefly Cron Token"
}

resource "kubernetes_secret" "firefly_environment" {
  metadata {
    name = "firefly-env"
    namespace = kubernetes_namespace.firefly.metadata.0.name
  }

  data = {
    APP_ENV   = "production"
    APP_DEBUG = false
    APP_KEY   = data.onepassword_item.firefly_app_key.password
    TZ        = "Europe/Amsterdam"
    TRUSTED_PROXIES = "**"
    DB_CONNECTION = "pgsql"
    DB_HOST = data.onepassword_item.database_firefly.hostname
    DB_PORT = data.onepassword_item.database_firefly.port
    DB_DATABASE = data.onepassword_item.database_firefly.database
    DB_USERNAME = data.onepassword_item.database_firefly.username
    DB_PASSWORD = data.onepassword_item.database_firefly.password
    STATIC_CRON_TOKEN = data.onepassword_item.firefly_cron_token.password
  }
}

### Plex
data "onepassword_item" "plex_token" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title    = "Plex Token"
}

### Floatplane
data "onepassword_item" "floatplane" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title    = "floatplane.com"
}