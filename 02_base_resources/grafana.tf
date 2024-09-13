resource "argocd_repository" "grafana" {
  repo = "https://grafana.github.io/helm-charts"
  name = "grafana"
  type = "helm"
  depends_on = [time_sleep.wait_for_argo]
}

resource "argocd_application" "grafana" {
  metadata {
    name = kubernetes_namespace.grafana.metadata.0.name
  }

  spec {
    project = argocd_project.argo-cd-system-project.metadata.0.name
    source {
      repo_url        = argocd_repository.grafana.repo
      chart           = "k8s-monitoring"
      target_revision = var.k8s_monitoring_chart_version
      
      helm {
        values = templatefile("helm-values/grafana.yaml", {
          grafana_token = data.onepassword_item.grafana_token.password
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
      sync_options = ["Validate=false", "ServerSideApply=true"]
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
      namespace = kubernetes_namespace.grafana.metadata.0.name
      name = "in-cluster"
    }
  }
}