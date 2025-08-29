resource "argocd_repository" "repo" {
  count = var.chart.repo_exists ? 0 : 1
  repo = "${var.chart.repo_url}"
  name = "${var.app_name}-repo"
  type = "helm"
  enable_oci = var.chart.oci_repo
}

resource "argocd_application" "app" {
  metadata {
    name = "${var.app_name}"
    # namespace = var.namespace
  }

  spec {
    project = "${var.argocd_project}"
    source {
      repo_url        = var.chart.repo_url
      chart           = var.chart.chart
      target_revision = var.chart.version

      helm {
        values = var.helm_values
      }
    }

    sync_policy {
      automated {
        prune       = true
        self_heal   = true
        allow_empty = true
      }

      sync_options = var.sync_options
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
      namespace = var.namespace
      name = "in-cluster"
    }
  }
}