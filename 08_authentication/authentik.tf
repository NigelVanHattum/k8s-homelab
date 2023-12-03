resource "kubernetes_namespace" "authentik" {
  metadata {
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
    name   = "authentik"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "argocd_repository" "authentik" {
  repo = "https://charts.goauthentik.io"
  name = "authentik"
  type = "helm"
}

resource "argocd_application" "authentik" {
  metadata {
    name = kubernetes_namespace.authentik.metadata.0.name
  }
  wait = true
  spec {
    project = "system"
    source {
      repo_url        = argocd_repository.authentik.repo
      chart           = argocd_repository.authentik.name
      target_revision = var.authentik_chart_version

      helm {
        values = file("helm-values/authentik.yaml")
        parameter {
            name = "authentik.secret_key"
            value = var.authentik_secret_key
        }
        parameter {
            name = "authentik.postgresql.password"
            value = var.postgresql_password
        }
        parameter {
            name = "geoip.accountId"
            value = var.geoIP_accountId
        } 
        parameter {
            name = "geoip.licenseKey"
            value = var.geoIP_licenseKey
        } 
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
      namespace = kubernetes_namespace.authentik.metadata.0.name
      name = "in-cluster"
    }
  }
}