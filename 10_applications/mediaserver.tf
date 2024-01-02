resource "kubernetes_namespace" "mediaserver" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "mediaserver"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

# resource "kubectl_manifest" "pv-plex-media" {
#   yaml_body          = file("manifests/pv-movies.yaml")
#   override_namespace = kubernetes_namespace.mediaserver.metadata.0.name

#   depends_on = [
#     kubernetes_namespace.mediaserver
#   ]
# }


resource "argocd_repository" "k8s-mediaserver" {
  repo = "https://github.com/kubealex/k8s-mediaserver-operator/blob/master/helm-charts"
  name = "k8s-mediaserver"
  type = "helm"
}

resource "argocd_application" "k8s-mediaserver" {
  metadata {
    name = kubernetes_namespace.mediaserver.metadata.0.name
  }

  spec {
    project = "apps"
    source {
      repo_url        = argocd_repository.k8s-mediaserver.repo
      chart           = argocd_repository.k8s-mediaserver.name
      target_revision = var.k8s_mediaserver_chart_version
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
      namespace = kubernetes_namespace.mediaserver.metadata.0.name
      name = "in-cluster"
    }
  }
}