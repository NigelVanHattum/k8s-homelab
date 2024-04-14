resource "argocd_repository" "authentik" {
  repo = "https://charts.goauthentik.io"
  name = "authentik"
  type = "helm"

  depends_on = [time_sleep.wait_for_argo, postgresql_database.authentik]
}

resource "kubernetes_config_map" "custom_authentication_flow" {
  metadata {
    name = "authentik-blueprints"
    namespace = kubernetes_namespace.authentik.metadata.0.name
  }

  data = {
    "flow-custom-authentication-flow.yaml" = "${file("${path.module}/manifests/authentik/flow-custom-authentication-flow.yaml")}"
  }
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
          authentik_secret_key = data.onepassword_item.key_authentik.password
          authentik_postgresql_password = data.onepassword_item.database_authentik.password
          geo_ip_secret = kubernetes_secret.authentik_geo_ip_credentials.metadata.0.name
          secret_name = kubernetes_secret.authentik_initial_credentials.metadata.0.name
          blueprint_configmap = kubernetes_config_map.custom_authentication_flow.metadata.0.name
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

data "authentik_stage" "default-authentication-identification" {
  name = "default-authentication-identification"
  depends_on = [argocd_application.authentik]
}

data "authentik_source" "inbuilt" {
  managed = "goauthentik.io/sources/inbuilt"
  depends_on = [argocd_application.authentik]
}

resource "authentik_source_oauth" "azure_ad" {
  name                  = "Azure AD"
  slug                  = "azure-ad"
  authentication_flow   = data.authentik_flow.default-source-authentication.id
  enrollment_flow       = ""
#   user_matching_mode    = "email_link"
  provider_type         = "openidconnect"
  consumer_key          = data.onepassword_item.authentik_azure_credentials.note_value
  consumer_secret       = data.onepassword_item.authentik_azure_credentials.password
  oidc_well_known_url   = "https://login.microsoftonline.com/${data.onepassword_item.azure_tenant_id.password}/v2.0/.well-known/openid-configuration"
}

resource "kubectl_manifest" "authentik_middleware" {
  yaml_body          = file("manifests/networking/authentik-middleware.yaml")
  override_namespace = kubernetes_namespace.traefik.metadata.0.name

  depends_on = [
    argocd_application.traefik,
    argocd_application.authentik
  ]
}
