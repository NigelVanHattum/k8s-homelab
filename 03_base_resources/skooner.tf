resource "argocd_repository" "skooner" {
  repo = "https://github.com/NigelVanHattum/k8s-homelab.git"
  name = "nigel-k8s-homelabe"
  type = "git"

  depends_on = [argocd_project.argo-cd-system-project]
}

resource "argocd_application" "skooner" {
  metadata {
    name = kubernetes_namespace.skooner.metadata.0.name
  }
  wait = true
  spec {
    project = "system"
    source {
      repo_url              = argocd_repository.skooner.repo
      path                  = "03_base_resources/manifests/skooner"
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
      namespace = kubernetes_namespace.skooner.metadata.0.name
      name = "in-cluster"
    }
  }
}

resource "kubernetes_service_account" "skooner_service_account" {
  metadata {
    name = "skooner-sa"
  }
}

resource "kubernetes_cluster_role_binding" "skooner_cluster_role_binding" {
  metadata {
    name = "skooner-sa"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "${kubernetes_service_account.skooner_service_account.metadata.0.name}"
    namespace = "${kubernetes_namespace.skooner.metadata.0.name}"
  }
}