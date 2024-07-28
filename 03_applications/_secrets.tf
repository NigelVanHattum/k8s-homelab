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

### SMTP
data "onepassword_item" "smtp" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = "Mailersend SMTP"
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

data "onepassword_item" "database_mealie" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = "postgresql-Mealie"
}

data "onepassword_item" "database_sonarr" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = "postgresql-Sonarr"
}

data "onepassword_item" "database_radarr" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = "postgresql-Radarr"
}

data "onepassword_item" "database_prowlarr" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = "postgresql-Prowlarr"
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

resource "kubernetes_secret" "sonarr_postgres" {
  metadata {
    name = "sonarr-postgres"
    namespace = kubernetes_namespace.plex_management.metadata.0.name
  }

  data = {
    username = data.onepassword_item.database_sonarr.username
    password = data.onepassword_item.database_sonarr.password
  }
}

resource "kubernetes_secret" "radarr_postgres" {
  metadata {
    name = "radarr-postgres"
    namespace = kubernetes_namespace.plex_management.metadata.0.name
  }

  data = {
    username = data.onepassword_item.database_radarr.username
    password = data.onepassword_item.database_radarr.password
  }
}

resource "kubernetes_secret" "prowlarr_postgres" {
  metadata {
    name = "prowlarr-postgres"
    namespace = kubernetes_namespace.plex_management.metadata.0.name
  }

  data = {
    username = data.onepassword_item.database_prowlarr.username
    password = data.onepassword_item.database_prowlarr.password
  }
}

### Floatplane
data "onepassword_item" "floatplane" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title    = "floatplane.com"
}

### Mealie
resource "kubernetes_secret" "mealie" {
  metadata {
    name = "mealie-db"
    namespace = kubernetes_namespace.mealie.metadata.0.name
  }

  data = {
    username    = data.onepassword_item.database_mealie.username
    password    = data.onepassword_item.database_mealie.password
  }
}

resource "kubernetes_secret" "mealie_smtp" {
  metadata {
    name = "mealie-smtp"
    namespace = kubernetes_namespace.mealie.metadata.0.name
  }

  data = {
    username    = data.onepassword_item.smtp.username
    password    = data.onepassword_item.smtp.password
    host        = data.onepassword_item.smtp.url
  }
}

resource "kubernetes_secret" "mealie_oidc" {
  metadata {
    name = "mealie-oidc"
    namespace = kubernetes_namespace.mealie.metadata.0.name
  }

  data = {
    config_url   = data.authentik_provider_oauth2_config.mealie.provider_info_url
    client_id    = authentik_provider_oauth2.mealie.client_id
  }
}