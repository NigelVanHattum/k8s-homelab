resource "argocd_application" "floatplane" {
  depends_on = [
    kubectl_manifest.pv_floatplane_db,
    kubectl_manifest.pv_floatplane_media
    ]
    
  metadata {
    name = kubernetes_namespace.floatplane.metadata.0.name
  }

  spec {
    project = argocd_project.argo_cd_apps_project.metadata.0.name
    source {
      repo_url        = argocd_repository.my_homelab.repo
      chart           = "floatplane-downloader"
      target_revision = var.floatplane_downloader_chart_version

      helm {
        values = templatefile("helm-values/floatplane.yaml",
        {
          username = data.onepassword_item.floatplane.username
          password = data.onepassword_item.floatplane.password
          plexToken = data.onepassword_item.plex_token.password
          mfaToken = var.floatplane_mfa_token
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
      namespace = kubernetes_namespace.floatplane.metadata.0.name
      name = "in-cluster"
    }
  }
}

resource "kubectl_manifest" "pv_floatplane_db" {
  yaml_body          = templatefile("manifests/storage/pv-floatplane-db.yaml", {
    ip_address = local.ip_address.nas_ip,
    k8s_rootmount = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.floatplane.metadata.0.name
}

resource "kubectl_manifest" "pv_floatplane_media" {
  yaml_body          = templatefile("manifests/storage/pv-floatplane-media.yaml", {
    ip_address = local.ip_address.nas_ip,
    plex_rootmount = local.file_share.nas_plex_root
  })
  override_namespace = kubernetes_namespace.floatplane.metadata.0.name
}