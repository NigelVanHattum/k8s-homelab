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

data "onepassword_item" "database_litellm" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title  = "postgresql-LiteLLM"
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
    config_url   = module.mealie.oauth_well_known_url
    client_id    = module.mealie.oauth_client_id
    client_secret    = module.mealie.oauth_client_secret
  }
}

### Open-WebUI
resource "kubernetes_secret" "open_webui_oidc" {
  metadata {
    name = "open-webui-oidc"
    namespace = kubernetes_namespace.open_webui.metadata.0.name
  }

  data = {
    name         = "authentik"
    config_url   = module.open_webui.oauth_well_known_url
    client_id    = module.open_webui.oauth_client_id
    client_secret    = module.open_webui.oauth_client_secret
  }
}

resource "kubernetes_secret" "open_webui_litellm" {
  metadata {
    name = "open-webui-litellm"
    namespace = kubernetes_namespace.open_webui.metadata.0.name
  }

  data = {
    api_key   = "${litellm_key.api_key.key}"
  }
}

### Lite LLM
data "onepassword_item" "litellm_masterkey" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title    = "Lite-LLM master key"
}

data "onepassword_item" "litellm_claude_ai" {
  vault = data.onepassword_vault.homelab_vault.uuid
  title    = "Claude.ai"
}

resource "kubernetes_secret" "litellm_masterkey" {
  metadata {
    name = local.litellm.masterKey_secret_name
    namespace = kubernetes_namespace.litellm.metadata.0.name
  }

  data = {
    (local.litellm.masterKey_key_name) = data.onepassword_item.litellm_masterkey.password
  }
}

resource "kubernetes_secret" "litellm_claude_ai" {
  metadata {
    name = local.litellm.lite_llm_api_keys
    namespace = kubernetes_namespace.litellm.metadata.0.name
  }

  data = {
    ANTHROPIC_API_KEY = data.onepassword_item.litellm_claude_ai.credential
  }
}

resource "kubernetes_secret" "litellm_db_credentials" {
  metadata {
    name = local.litellm.db_secret_name
    namespace = kubernetes_namespace.litellm.metadata.0.name
  }

  data = {
    (local.litellm.db_user_key) = data.onepassword_item.database_litellm.username
    (local.litellm.db_password_key) = data.onepassword_item.database_litellm.password
  }
}