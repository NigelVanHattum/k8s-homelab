resource "argocd_repository" "authentik" {
  repo = "https://charts.goauthentik.io"
  name = "authentik"
  type = "helm"

  depends_on = [postgresql_database.authentik]
}

resource "argocd_application" "authentik" {
  metadata {
    name = kubernetes_namespace.authentik.metadata.0.name
  }
  wait = true
  spec {
    project = argocd_project.argo-cd-system-project.metadata.0.name
    source {
      repo_url        = argocd_repository.authentik.repo
      chart           = argocd_repository.authentik.name
      target_revision = var.authentik_chart_version

      helm {
        values = templatefile("helm-values/authentik.yaml", {
          authentik_secret_key = var.authentik_secret_key
          authentik_postgresql_password = var.postgresql_authentik_password
          authentik_geoip_account_id = var.geoIP_accountId
          authentik_geoip_license_key = var.geoIP_licenseKey
          secret_name = kubernetes_secret.authentik_initial_credentials.metadata.0.name
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
      namespace = kubernetes_namespace.authentik.metadata.0.name
      name = "in-cluster"
    }
  }
  depends_on = [kubectl_manifest.nfs_storage_class_authentik]
}