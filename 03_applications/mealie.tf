# resource "kubectl_manifest" "mealie_ingress-public" {
#   yaml_body          = file("manifests/firefly/ingress-public.yaml")
#   override_namespace = kubernetes_namespace.firefly.metadata.0.name
# }

resource "authentik_provider_proxy" "authentik_mealie_provider" {
  name               = "mealie"
  mode               = "forward_single"
  external_host      = "https://mealie.nigelvanhattum.nl"
  authorization_flow = data.authentik_flow.default_authorization_flow.id
}

resource "authentik_application" "authentik_mealie_application" {
  name              = "mealie"
  slug              = "mealie"
  protocol_provider = authentik_provider_proxy.authentik_mealie_provider.id
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