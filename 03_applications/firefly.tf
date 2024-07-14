resource "argocd_repository" "firefly" {
  repo = "https://firefly-iii.github.io/kubernetes"
  name = "firefly-iii"
  type = "helm"
}

resource "authentik_provider_proxy" "authentik_firefly_provider" {
  name               = "firefly"
  mode               = "forward_single"
  external_host      = "https://finance.nigelvanhattum.nl"
  authorization_flow = data.authentik_flow.default_authorization_flow.id
}

resource "authentik_application" "authentik_firefly_application" {
  name              = "firefly"
  slug              = "firefly"
  protocol_provider = authentik_provider_proxy.authentik_firefly_provider.id
}

resource "argocd_application" "firefly" {
  metadata {
    name = kubernetes_namespace.firefly.metadata.0.name
  }

  spec {
    project = "apps"
    source {
      repo_url        = argocd_repository.firefly.repo
      chart           = "firefly-iii-stack"
      target_revision = var.firefly_chart_version

      helm {
        values = templatefile("helm-values/firefly.yaml",
        {
          firefly_secret_env = kubernetes_secret.firefly_environment.metadata.0.name
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
      namespace = kubernetes_namespace.firefly.metadata.0.name
      name = "in-cluster"
    }
  }
}

resource "kubectl_manifest" "firefly_ingress-local" {
  yaml_body          = file("manifests/ingress/firefly-ingress-local.yaml")
  override_namespace = kubernetes_namespace.firefly.metadata.0.name
}

resource "kubectl_manifest" "firefly_import-local" {
  yaml_body          = file("manifests/ingress/firefly-importer-local.yaml")
  override_namespace = kubernetes_namespace.firefly.metadata.0.name
}

resource "kubectl_manifest" "firefly_ingress-public" {
  yaml_body          = file("manifests/ingress/firefly-ingress-public.yaml")
  override_namespace = kubernetes_namespace.firefly.metadata.0.name
}