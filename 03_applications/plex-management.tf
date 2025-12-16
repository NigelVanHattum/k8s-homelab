resource "kubectl_manifest" "pv_p2p" {
  yaml_body = templatefile("manifests/storage/pv-p2p.yaml", {
    pv_name         = local.file_share.pv_names.p2p_root, 
    ip_address      = local.ip_address.nas_ip,
    p2p_root        = local.file_share.p2p_root
  })
  override_namespace = kubernetes_namespace.plex_management.metadata.0.name
}

resource "kubectl_manifest" "pv_prowlarr_config" {
  yaml_body = templatefile("manifests/storage/pv-prowlarr-config.yaml", {
    pv_name         = local.file_share.pv_names.prowlarr_config, 
    ip_address      = local.ip_address.nas_ip,
    k8s_rootmount   = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.plex_management.metadata.0.name
}

resource "kubectl_manifest" "pv_sonarr_config" {
  yaml_body = templatefile("manifests/storage/pv-sonarr-config.yaml", {
    pv_name         = local.file_share.pv_names.sonarr_config, 
    ip_address      = local.ip_address.nas_ip,
    k8s_rootmount   = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.plex_management.metadata.0.name
}

resource "kubectl_manifest" "pv_plex_series" {
  yaml_body = templatefile("manifests/storage/pv-plex-series.yaml", {
    pv_name         = local.file_share.pv_names.plex_serie, 
    ip_address      = local.ip_address.nas_ip,
    nas_plex_root   = local.file_share.nas_plex_root
  })
  override_namespace = kubernetes_namespace.plex_management.metadata.0.name
}

resource "kubectl_manifest" "pv_ombi_config" {
  yaml_body = templatefile("manifests/storage/pv-ombi-config.yaml", {
    pv_name         = local.file_share.pv_names.ombi_config, 
    ip_address      = local.ip_address.nas_ip,
    k8s_rootmount   = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.plex_management.metadata.0.name
}

resource "kubectl_manifest" "pv_radarr_config" {
  yaml_body = templatefile("manifests/storage/pv-radarr-config.yaml", {
    pv_name         = local.file_share.pv_names.radarr_config, 
    ip_address      = local.ip_address.nas_ip,
    k8s_rootmount   = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.plex_management.metadata.0.name
}

resource "kubectl_manifest" "pv_plex_007" {
  yaml_body = templatefile("manifests/storage/pv-plex-007.yaml", {
    pv_name         = local.file_share.pv_names.plex_007, 
    ip_address      = local.ip_address.nas_ip,
    nas_plex_root   = local.file_share.nas_plex_root
  })
  override_namespace = kubernetes_namespace.plex_management.metadata.0.name
}

resource "kubectl_manifest" "pv_plex_movies" {
  yaml_body = templatefile("manifests/storage/pv-plex-movies.yaml", {
    pv_name         = local.file_share.pv_names.plex_movie, 
    ip_address      = local.ip_address.nas_ip,
    nas_plex_root   = local.file_share.nas_plex_root
  })
  override_namespace = kubernetes_namespace.plex_management.metadata.0.name
}

resource "kubectl_manifest" "pv_tdarr_config" {
  yaml_body = templatefile("manifests/storage/pv-tdarr-config.yaml", {
    pv_name         = local.file_share.pv_names.tdarr_config, 
    ip_address      = local.ip_address.nas_ip,
    k8s_rootmount   = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.plex_management.metadata.0.name
}

resource "kubectl_manifest" "pv_tdarr_server" {
  yaml_body = templatefile("manifests/storage/pv-tdarr-server.yaml", {
    pv_name         = local.file_share.pv_names.tdarr_server, 
    ip_address      = local.ip_address.nas_ip,
    k8s_rootmount   = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.plex_management.metadata.0.name
}

resource "kubectl_manifest" "pv_tdarr_cache" {
  yaml_body = templatefile("manifests/storage/pv-tdarr-cache.yaml", {
    pv_name         = local.file_share.pv_names.tdarr_cache, 
    ip_address      = local.ip_address.nas_ip,
    k8s_rootmount   = local.file_share.nas_root_mount
  })
  override_namespace = kubernetes_namespace.plex_management.metadata.0.name
}

resource "kubectl_manifest" "tdarr_server_socket" {
  validate_schema = false
  yaml_body = templatefile("${path.module}/manifests/ingress/tdarr-server.yaml", {
    service_name = "plex-management-tdarr-server"
  })
  ## wait does not work, there is no status viewer for it
  # wait {
  #   rollout = true
  # }
  override_namespace = kubernetes_namespace.plex_management.metadata.0.name
}



resource "argocd_application" "plex-management" {
    
  metadata {
    name = "plex-management"
  }

  spec {
    project = argocd_project.argo_cd_apps_project.metadata.0.name
    source {
      repo_url        = data.terraform_remote_state.base_resources.outputs.homelab_helm_repo
      chart           = "plex-management"
      target_revision = var.plex_management_chart_version

      helm {
        values = templatefile("helm-values/plex-management.yaml",
        {
          ## database
          postgres_host = local.database.read_write_service
          postgres_port = "5432"
          ## file share permissions
          PUID = local.file_share.PUID
          PGID = local.file_share.PGID
          ## Shared PVC
          pv_p2p_name = local.file_share.pv_names.p2p_root,
          pvc_p2p_name = local.file_share.pv_names.pvc_p2p,
          p2p_containerPath = format("%s/%s",local.file_share.p2p_root,"Complete"),
          ## Prowlarr
          prowlarr_version = local.prowlarr_version
          pv_prowlarr_name = local.file_share.pv_names.prowlarr_config,
          postgres_prowlarr = kubernetes_secret.prowlarr_postgres.metadata.0.name
          ## Sonarr
          sonarr_version = local.sonarr_version
          pv_sonarr_config = local.file_share.pv_names.sonarr_config,
          pv_series = local.file_share.pv_names.plex_serie,
          series_containerPath = format("%s/%s",local.file_share.nas_plex_root,"Series"),
          postgres_sonarr = kubernetes_secret.sonarr_postgres.metadata.0.name
          ## Radarr
          radarr_version = local.radarr_version
          pv_radarr_config = local.file_share.pv_names.radarr_config,
          pv_007 = local.file_share.pv_names.plex_007,
          pv_movies = local.file_share.pv_names.plex_movie,
          movies_containerPath = format("%s/%s",local.file_share.nas_plex_root,"Movies"),
          movies_007_containerPath = format("%s/%s",local.file_share.nas_plex_root,"007"),
          postgres_radarr = kubernetes_secret.radarr_postgres.metadata.0.name
          ## Ombi
          ombi_version = local.ombi_version
          pv_ombi_config = local.file_share.pv_names.ombi_config
          ## Tdarr
          tdarr_version   = local.tdarr_version
          pv_tdarr_server = local.file_share.pv_names.tdarr_server
          pv_tdarr_config = local.file_share.pv_names.tdarr_config
          pv_tdarr_cache = local.file_share.pv_names.tdarr_cache
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
      namespace = kubernetes_namespace.plex_management.metadata.0.name
      name = "in-cluster"
    }
  }
}