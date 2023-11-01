resource "kubernetes_namespace" "metal-lb" {
  metadata {
    name   = "metal-lb"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "argocd_repository" "metal-lb" {
  repo = "https://metallb.github.io/metallb"
  name = "metallb"
  type = "helm"
}

resource "argocd_application" "metal-lb" {
  metadata {
    name = kubernetes_namespace.metal-lb.metadata.0.name
  }
  wait = true
  spec {
    project = "system"
    source {
      repo_url        = argocd_repository.metal-lb.repo
      chart           = argocd_repository.metal-lb.name
      target_revision = var.metallb_version

    #   helm {
    #     values = file("helm-values/helm.yaml")
    #   }
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
      namespace = kubernetes_namespace.metal-lb.metadata.0.name
      name = "in-cluster"
    }
  }
}

resource "kubectl_manifest" "traefik_ip_address_pool" {
  yaml_body          = file("manifests/traefik-addresspool.yaml")
  override_namespace = kubernetes_namespace.metal-lb.metadata.0.name

  depends_on = [
    kubernetes_namespace.metal-lb,
    argocd_application.metal-lb,
  ]
}

resource "kubectl_manifest" "extra_ip_address_pool" {
  yaml_body          = file("manifests/extra-addresspool.yaml")
  override_namespace = kubernetes_namespace.metal-lb.metadata.0.name

  depends_on = [
    kubernetes_namespace.metal-lb,
    argocd_application.metal-lb,
  ]
}

resource "kubectl_manifest" "metallb_ip_advertisement" {
  yaml_body          = file("manifests/advertisement.yaml")
  override_namespace = kubernetes_namespace.metal-lb.metadata.0.name

  depends_on = [
    kubernetes_namespace.metal-lb,
    argocd_application.metal-lb,
  ]
}