resource "argocd_repository" "authentik" {
  repo = "https://charts.goauthentik.io"
  name = "authentik"
  type = "helm"

  depends_on = [time_sleep.wait_for_argo, postgresql_database.authentik]
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

data "authentik_flow" "default-source-authentication" {
  slug = "default-source-authentication"
  depends_on = [argocd_application.authentik]
}

data "authentik_flow" "default-enrollment-flow" {
  slug = "default-source-enrollment"
  depends_on = [argocd_application.authentik]
}

resource "authentik_source_oauth" "azure_ad" {
  name                  = "Azure AD"
  slug                  = "azure-ad"
  authentication_flow   = data.authentik_flow.default-source-authentication.id
  enrollment_flow       = data.authentik_flow.default-enrollment-flow.id
#   user_matching_mode    = "email_link"
  provider_type         = "openidconnect"
  consumer_key          = var.authentik_azure_client_id
  consumer_secret       = var.authentik_azure_client_secret
  oidc_well_known_url   = "https://login.microsoftonline.com/${var.azure_tenant_id}/v2.0/.well-known/openid-configuration"
}