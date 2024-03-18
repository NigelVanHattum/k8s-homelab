resource "argocd_repository" "traefik" {
  repo = "https://traefik.github.io/charts"
  name = "traefik"
  type = "helm"
  depends_on = [time_sleep.wait_for_argo]
}

resource "argocd_application" "traefik" {
  metadata {
    name = kubernetes_namespace.traefik.metadata.0.name
  }
  wait = true
  spec {
    project = argocd_project.argo-cd-system-project.metadata.0.name
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
  depends_on = [
    kubectl_manifest.nfs_storage_class_traefik,
    kubectl_manifest.traefik_ip_address_pool
  ]
}

