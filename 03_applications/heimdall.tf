resource "kubectl_manifest" "pv_heimdall_config" {
  yaml_body = templatefile("manifests/storage/pv-prowlarr-config.yaml", {
    pv_name       = local.file_share.pv_names.heimdall_config,
    ip_address    = local.ip_address.nas_ip,
    k8s_rootmount = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.heimdall.metadata.0.name
}

resource "argocd_application" "heimdall" {
  depends_on = [
    argocd_project.argo_cd_apps_project,
    kubectl_manifest.pv_heimdall_config
  ]
  metadata {
    name = kubernetes_namespace.heimdall.metadata.0.name
  }

  spec {
    project = "apps"
    source {
      repo_url        = data.terraform_remote_state.base_resources.outputs.homelab_helm_repo
      chart           = "heimdall"
      target_revision = var.heimdall_chart_version

      helm {
        values = templatefile("helm-values/heimdall.yaml",
          {
            PUID    = local.file_share.PUID
            PGID    = local.file_share.PGID
            pv_name = local.file_share.pv_names.heimdall_config
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
      namespace = kubernetes_namespace.heimdall.metadata.0.name
      name      = "in-cluster"
    }
  }
}