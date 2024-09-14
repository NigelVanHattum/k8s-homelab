resource "argocd_repository" "ollama" {
  repo = "https://otwld.github.io/ollama-helm/"
  name = "ollama"
  type = "helm"
}

resource "kubectl_manifest" "pv_ollama" {
  yaml_body = templatefile("manifests/storage/pv-ollama.yaml", {
    pv_name         = local.file_share.pv_names.ollama, 
    ip_address      = local.ip_address.nas_ip,
    k8s_rootmount        = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.ollama.metadata.0.name
}

resource "argocd_application" "ollama" {
  metadata {
    name = kubernetes_namespace.ollama.metadata.0.name
  }

  spec {
    project = "apps"
    source {
      repo_url        = argocd_repository.ollama.repo
      chart           = "ollama"
      target_revision = var.ollama_chart_version

      helm {
        values = templatefile("helm-values/ollama.yaml",
        {
            pv_name = local.file_share.pv_names.ollama
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
      namespace = kubernetes_namespace.ollama.metadata.0.name
      name = "in-cluster"
    }
  }
}
