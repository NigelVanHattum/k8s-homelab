module "mealie" {
  source = "../modules/authentik-oauth-app"

  app_name              = "mealie"
  authorization_flow_id = data.authentik_flow.default_authorization_flow.id
  invalidation_flow_id  = data.authentik_flow.default_provider_invalidation_flow.id
  property_mappings     = data.authentik_property_mapping_provider_scope.oidc_mapping.ids
  
  redirect_uris = [
    "https://mealie.nigelvanhattum.nl/login*",
    "https://mealie.local.nigelvanhattum.nl/login*"
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

resource "kubectl_manifest" "pv_mealie" {
  yaml_body = templatefile("manifests/storage/pv-mealie.yaml", {
    pv_name         = local.file_share.pv_names.mealie, 
    ip_address      = local.ip_address.nas_ip,
    k8s_rootmount        = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.mealie.metadata.0.name
}

resource "argocd_application" "mealie" {
  metadata {
    name = kubernetes_namespace.mealie.metadata.0.name
  }

  spec {
    project = "apps"
    source {
      repo_url        = argocd_repository.my_homelab.repo
      chart           = "mealie"
      target_revision = var.mealie_chart_version

      helm {
        values = templatefile("helm-values/mealie.yaml",
        {
          mealie_version            = local.mealie_version
          pv_name                   = local.file_share.pv_names.mealie
          PUID                      = local.file_share.PUID
          PGID                      = local.file_share.PGID
          postgres_secret           = kubernetes_secret.mealie.metadata.0.name
          postgres_host             = data.onepassword_item.database_mealie.hostname
          postgres_port             = data.onepassword_item.database_mealie.port
          postgres_database_name    = data.onepassword_item.database_mealie.database
          smtp_credentials          = kubernetes_secret.mealie_smtp.metadata.0.name
          oidc_config               = kubernetes_secret.mealie_oidc.metadata.0.name
          authentik_admin_group     = local.authentik.group_admin
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
      namespace = kubernetes_namespace.mealie.metadata.0.name
      name = "in-cluster"
    }
  }
}