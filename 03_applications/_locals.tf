locals {
    domain = "nigelvanhattum.nl"
    onepassword = {
        vault_name = "Homelab"
        azure_tenant = "Azure tenant"
        argo = {
            admin = "ArgoCD admin login"
            azure_secret = "ArgoCD Azure Secret"
        }
    }
    ip_address = {
        ingress = "10.0.49.25"
        extra_pool = "10.0.49.40-10.0.49.50"
        nas_ip = "192.168.20.3"
    }
    file_share = {
        nas_root_mount = "/volume1/k8s"
        nas_plex_root = "/volume1/Plex-Media"
        p2p_root = "/volume2/P2P"
        PUID: 1036
        PGID: 100
        pv_names = {
            p2p_root = "pv-p2p"
            pvc_p2p = "pvc-p2p"
            prowlarr_config = "pv-prowlarr-config"
            ombi_config = "pv-ombi-config"
            radarr_config = "pv-radarr-config"
            sonarr_config = "pv-sonarr-config"
            tdarr_server = "pv-tdarr-server"
            tdarr_config = "pv-tdarr-config"
            tdarr_cache = "pv-tdarr-cache"
            plex_007 = "pv-plex-007"
            plex_movie = "pv-plex-movie"
            plex_serie = "pv-plex-serie"
            heimdall_config = "pv-heimdall-config"
            mealie = "pv-mealie"
            ollama = "pv-ollama"
            open_webui = "pv-open-webui"
            open_webui-pipelines = "pv-open-webui-pipelines"
        }
    }
    database = {
        backup_c2_bucket = "postgresql-backup"
        read_write_service = "postgresql-cluster-postgresql-main-rw.postgresql.svc.cluster.local"
    }
    authentik = {
        group_admin     = "Admin"
        group_household = "Household"
        group_guests    = "Guests"
    }
}