resource "random_uuid" "authentik_mealie_oauth_client_id" {
}

resource "authentik_provider_oauth2" "mealie" {
  name                = "mealie"
  client_id           = random_uuid.authentik_mealie_oauth_client_id.result
  authorization_flow  = data.authentik_flow.default_authorization_flow.id
  redirect_uris       = ["https://mealie.nigelvanhattum.nl/login*", "https://mealie.local.nigelvanhattum.nl/login*"]
  client_type = "public"
  property_mappings = data.authentik_scope_mapping.oidc_mapping.ids
}

data "authentik_provider_oauth2_config" "mealie" {
  provider_id = authentik_provider_oauth2.mealie.id
}

resource "authentik_application" "mealie" {
  name              = "mealie"
  slug              = "mealie"
  protocol_provider = authentik_provider_oauth2.mealie.id
}

resource "authentik_policy_binding" "mealie_admin" {
  target = authentik_application.mealie.uuid
  group  = data.authentik_group.admin.id
  order  = 0
}

resource "authentik_policy_binding" "mealie_household" {
  target = authentik_application.mealie.uuid
  group  = data.authentik_group.houshold.id
  order  = 1
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