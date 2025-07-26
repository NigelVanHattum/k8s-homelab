resource "argocd_repository" "iscsi_csi_driver" {
  repo = "https://zebernst.github.io/synology-csi-talos"
  name = "csi-driver-iscsi"
  type = "helm"
  depends_on = [time_sleep.wait_for_argo]
}

resource "argocd_application" "iscsi_csi_driver" {
  metadata {
    name = kubernetes_namespace.iscsi_csi_driver.metadata.0.name
  }

  spec {
    project = argocd_project.argo-cd-system-project.metadata.0.name
    source {
      repo_url        = argocd_repository.iscsi_csi_driver.repo
      chart           = "synology-csi"
      target_revision = var.iscsi_csi_driver_chart_version
    
      helm {
        values = templatefile("helm-values/iscsi.yaml", {
          nas_ip = local.ip_address.nas_ip,
          iscsi_username = data.onepassword_item.iscsi_user.username
          iscsi_password = data.onepassword_item.iscsi_user.password
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
      namespace = kubernetes_namespace.iscsi_csi_driver.metadata.0.name
      name = "in-cluster"
    }
  }
}