### Authentik config
module "open_webui" {
  source = "../modules/authentik-oauth-app"

  app_name              = "open-webui"
  authorization_flow_id = data.authentik_flow.default_authorization_flow.id
  invalidation_flow_id  = data.authentik_flow.default_provider_invalidation_flow.id
  property_mappings     = data.authentik_property_mapping_provider_scope.oidc_mapping.ids
  
  redirect_uris = [
    "https://ai.nigelvanhattum.nl/oauth/oidc/callback*",
    "https://ai.local.nigelvanhattum.nl/oauth/oidc/callback*"
  ]
  
  group_bindings = [
    {
      group_id = data.authentik_group.admin.id
      order    = 0
    },
    {
      group_id = data.authentik_group.household.id
      order    = 1
    }
  ]
}

# Waiting for https://github.com/ncecere/terraform-provider-litellm/issues/3
resource "litellm_key" "api_key" {
  # models               = [ "All Team Models" ]
  max_budget           = 20.0
  budget_duration      = "30d"
  allowed_cache_controls = ["no-cache", "max-age=3600"]
  soft_budget          = 10.0
  key_alias            = "open-webui"
  aliases              = {
    "gpt-3.5-turbo" = "chatgpt"
  }

  depends_on = [ argocd_application.lite_llm ]
}

### Open-WebUI deployment

resource "argocd_repository" "open_webui" {
  repo = "https://helm.openwebui.com/"
  name = "open-webui"
  type = "helm"
}

resource "kubectl_manifest" "pv_ollama" {
  yaml_body = templatefile("manifests/storage/pv-ollama.yaml", {
    pv_name         = local.file_share.pv_names.ollama, 
    ip_address      = local.ip_address.nas_ip,
    k8s_rootmount        = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.open_webui.metadata.0.name
}

resource "kubectl_manifest" "pv_open_webui" {
  yaml_body = templatefile("manifests/storage/pv-open-webui.yaml", {
    pv_name         = local.file_share.pv_names.open_webui, 
    ip_address      = local.ip_address.nas_ip,
    k8s_rootmount        = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.open_webui.metadata.0.name
}

resource "kubectl_manifest" "pv_open_webui_pipelines" {
  yaml_body = templatefile("manifests/storage/pv-open-webui-pipelines.yaml", {
    pv_name         = local.file_share.pv_names.open_webui-pipelines, 
    ip_address      = local.ip_address.nas_ip,
    k8s_rootmount        = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.open_webui.metadata.0.name
}

resource "argocd_application" "open_webui" {
  metadata {
    name = kubernetes_namespace.open_webui.metadata.0.name
  }

  spec {
    project = "apps"
    source {
      repo_url        = argocd_repository.open_webui.repo
      chart           = "open-webui"
      target_revision = var.open_webui_chart_version

      helm {
        values = templatefile("helm-values/open-webui.yaml",
        {
            storageClass = "nfs-csi-applications"
            ollama_pv_name = local.file_share.pv_names.ollama
            oidc_secret_name = kubernetes_secret.open_webui_oidc.metadata.0.name
            litellm_secret_name = kubernetes_secret.open_webui_litellm.metadata.0.name
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
      namespace = kubernetes_namespace.open_webui.metadata.0.name
      name = "in-cluster"
    }
  }
}
