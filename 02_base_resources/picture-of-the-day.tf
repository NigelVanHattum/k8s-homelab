resource "argocd_repository" "k8s-homelab" {
  repo = "https://github.com/NigelVanHattum/k8s-homelab-deployments.git"
  name = "nigel-k8s-homelab"
  type = "git"
  depends_on = [time_sleep.wait_for_argo]
}

resource "argocd_application" "picture_of_the_day" {
  metadata {
    name = kubernetes_namespace.picture_of_the_day.metadata.0.name
  }
  wait = true
  spec {
    project = argocd_project.argo-cd-system-project.metadata.0.name
    source {
      repo_url              = argocd_repository.k8s-homelab.repo
      path                  = "picture-of-the-day"
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
      namespace = kubernetes_namespace.picture_of_the_day.metadata.0.name
      name = "in-cluster"
    }
  }
}