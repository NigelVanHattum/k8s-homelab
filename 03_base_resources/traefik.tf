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

resource "argocd_repository" "traefik" {
  repo = "https://traefik.github.io/charts"
  name = "traefik"
  type = "helm"
}

resource "argocd_application" "traefik" {
  metadata {
    name = kubernetes_namespace.traefik.metadata.0.name
  }
  wait = true
  spec {
    project = "system"
    source {
      repo_url        = argocd_repository.traefik.repo
      chart           = argocd_repository.traefik.name
      target_revision = var.traefik_chart_version

      helm {
        values = file("helm-values/traefik.yaml")
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
      namespace = kubernetes_namespace.traefik.metadata.0.name
      name = "in-cluster"
    }
  }
}

resource "kubectl_manifest" "authentik_middleware" {
  yaml_body          = file("manifests/networking/authentik-middleware.yaml")
  override_namespace = kubernetes_namespace.traefik.metadata.0.name

  depends_on = [
    kubernetes_namespace.traefik
  ]
}

