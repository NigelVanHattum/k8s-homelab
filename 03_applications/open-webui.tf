### Authentik config
resource "random_uuid" "authentik_open_webui_oauth_client_id" {
}

resource "authentik_provider_oauth2" "open_webui" {
  name                        = "open-webui"
  client_id                   = random_uuid.authentik_open_webui_oauth_client_id.result
  authorization_flow          = data.authentik_flow.default_authorization_flow.id
  allowed_redirect_uris       = [
    {
      matching_mode = "regex",
      url           = "https://ai.nigelvanhattum.nl/oauth/oidc/callback*",
    },
    {
      matching_mode = "regex",
      url           = "https://ai.local.nigelvanhattum.nl/oauth/oidc/callback*",
    }
  ]
  invalidation_flow           = data.authentik_flow.default_provider_invalidation_flow.id
  property_mappings           = data.authentik_property_mapping_provider_scope.oidc_mapping.ids
}

data "authentik_provider_oauth2_config" "open_webui" {
  provider_id = authentik_provider_oauth2.open_webui.id
}

resource "authentik_application" "open_webui" {
  name              = "open-webui"
  slug              = "openwebui"
  protocol_provider = authentik_provider_oauth2.open_webui.id
}

resource "authentik_policy_binding" "open_webui_admin" {
  target = authentik_application.open_webui.uuid
  group  = data.authentik_group.admin.id
  order  = 0
}

resource "authentik_policy_binding" "open_webui_household" {
  target = authentik_application.open_webui.uuid
  group  = data.authentik_group.household.id
  order  = 1
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
