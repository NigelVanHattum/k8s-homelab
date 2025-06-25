resource "argocd_repository" "metallb" {
  repo = "https://metallb.github.io/metallb"
  name = "metallb"
  type = "helm"
  depends_on = [time_sleep.wait_for_argo]
}

resource "argocd_application" "metallb" {
  metadata {
    name = kubernetes_namespace.metallb.metadata.0.name
  }
  wait = true
  spec {
    project = argocd_project.argo-cd-system-project.metadata.0.name
    source {
      repo_url        = argocd_repository.metallb.repo
      chart           = argocd_repository.metallb.name
      target_revision = var.metallb_chart_version
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
      namespace = kubernetes_namespace.metallb.metadata.0.name
      name = "in-cluster"
    }
  }
}

resource "kubectl_manifest" "traefik_ip_address_pool" {
  yaml_body          = templatefile("manifests/networking/traefik-addresspool.yaml", {
    traefik_ip = local.ip_address.ingress
  })
  override_namespace = kubernetes_namespace.metallb.metadata.0.name

  depends_on = [
    argocd_application.metallb
  ]
}

resource "kubectl_manifest" "adguard_ip_address_pool" {
  yaml_body          = templatefile("manifests/networking/adguard-addresspool.yaml", {
    adguard_ipv4 = local.ip_address.adguard_ipv4,
    adguard_ipv6 = local.ip_address.adguard_ipv6
  })
  override_namespace = kubernetes_namespace.metallb.metadata.0.name

  depends_on = [
    argocd_application.metallb
  ]
}

resource "kubectl_manifest" "extra_ip_address_pool" {
  yaml_body          = templatefile("manifests/networking/extra-addresspool.yaml", {
    extra_ips = local.ip_address.extra_pool
  })
  override_namespace = kubernetes_namespace.metallb.metadata.0.name

  depends_on = [
    argocd_application.metallb
  ]
}

resource "kubectl_manifest" "metallb_ip_advertisement" {
  yaml_body          = file("manifests/networking/advertisement.yaml")
  override_namespace = kubernetes_namespace.metallb.metadata.0.name

  depends_on = [
    argocd_application.metallb
  ]
}