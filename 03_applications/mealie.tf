resource "random_uuid" "authentik_mealie_oauth_client_id" {
}

resource "authentik_provider_oauth2" "mealie" {
  name                = "mealie"
  client_id           = random_uuid.authentik_mealie_oauth_client_id.result
  authorization_flow  = data.authentik_flow.default_authorization_flow.id
  redirect_uris       = ["https://mealie.nigelvanhattum.nl/login", "https://mealie.local.nigelvanhattum.nl/login"]
}

data "authentik_provider_oauth2_config" "mealie" {
  provider_id = authentik_provider_oauth2.mealie.id
}

resource "authentik_application" "authentik_mealie_application" {
  name              = "mealie"
  slug              = "mealie"
  protocol_provider = authentik_provider_oauth2.mealie.id
}

resource "argocd_application" "mealie" {
  metadata {
    name = kubernetes_namespace.mealie.metadata.0.name
  }

  spec {
    project = "apps"
    source {
      repo_url        = argocd_repository.my_homelab.repo
      chart           = "mealie"
      target_revision = var.mealie_chart_version

      helm {
        values = templatefile("helm-values/mealie.yaml",
        {
          PUID                      = local.file_share.PUID
          PGID                      = local.file_share.PGID
          postgres_secret           = kubernetes_secret.mealie.metadata.0.name
          postgres_host             = data.onepassword_item.database_mealie.hostname
          postgres_port             = data.onepassword_item.database_mealie.port
          postgres_database_name    = data.onepassword_item.database_mealie.database
          smtp_credentials          = kubernetes_secret.mealie_smtp.metadata.0.name
          oidc_config               = kubernetes_secret.mealie_oidc.metadata.0.name
        })
      }
    }

    sync_policy {
      automated {
        prune       = true
        self_heal   = true
        allow_empty = true
      }
      # Only available from ArgoCD 1.5.0 onwards
      sync_options = ["Validate=false"]
      retry {
        limit = "5"
        backoff {
          duration     = "30s"
          max_duration = "2m"
          factor       = "2"
        }
      }
    }

    destination {
      namespace = kubernetes_namespace.mealie.metadata.0.name
      name = "in-cluster"
    }
  }
}