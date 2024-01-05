resource "argocd_repository" "influxdb" {
  repo = "https://helm.influxdata.com"
  name = "influxdb2"
  type = "helm"

  depends_on = [argocd_project.argo-cd-system-project]
}

resource "argocd_application" "influxdb" {
  metadata {
    name = kubernetes_namespace.influxdb.metadata.0.name
  }
  wait = true
  spec {
    project = "system"
    source {
      repo_url        = argocd_repository.influxdb.repo
      chart           = argocd_repository.influxdb.name
      target_revision = var.influxdb_chart_version

      helm {
        values = file("helm-values/influxdb.yaml")
        parameter {
            name = "adminUser.existingSecret"
            value = "${var.influxdb_secret_name}"
        }
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
      namespace = kubernetes_namespace.influxdb.metadata.0.name
      name = "in-cluster"
    }
  }
}