locals {
  litellm = {
    masterKey_secret_name = "master-key"
    masterKey_key_name = "key"
    db_secret_name = "postgres-credentials"
    db_user_key = "username"
    db_password_key = "password"
    lite_llm_api_keys = "lite-llm-api-key"
  }
}

resource "argocd_repository" "litellm" {
  repo = "ghcr.io/berriai"
  name = "litellm"
  type = "helm"
  enable_oci = true
}

resource "argocd_application" "lite_llm" {
  metadata {
    name = kubernetes_namespace.litellm.metadata.0.name
  }

  spec {
    project = "apps"
    source {
      repo_url        = argocd_repository.litellm.repo
      chart           = "litellm-helm"
      target_revision = var.litellm_chart_version

      helm {
        values = templatefile("helm-values/litellm.yaml",
        {
          masterkey_secret    = local.litellm.masterKey_secret_name
          masterkey_secret_key = local.litellm.masterKey_key_name
          lite_llm_api_keys_secret = local.litellm.lite_llm_api_keys
          database_endpoint    = data.onepassword_item.database_litellm.hostname
          database = data.onepassword_item.database_litellm.database
          database_secret    = local.litellm.db_secret_name
          database_user_key = local.litellm.db_user_key
          database_password_key = local.litellm.db_password_key
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
      namespace = kubernetes_namespace.litellm.metadata.0.name
      name = "in-cluster"
    }
  }
  depends_on = [ argocd_project.argo_cd_apps_project ]
}