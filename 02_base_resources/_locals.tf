locals {
    domain = "nigelvanhattum.nl"
    onepassword = {
        vault_name = "Homelab"
        azure_tenant = "Azure tenant"
        dsm_iscsi_user = "talos-csi-driver"
        argo = {
            admin = "ArgoCD admin login"
            azure_secret = "ArgoCD Azure Secret"
        }
        traefik = {
            cloudflare_api_token = "Cloudflare DNS token"
        }
        postgresql = {
            synology_c2 = "Synology C2 - postgresql 17"
            postgres_user = "postgresql-postgres"
            authentik_user = "postgresql-Authentik"
            firefly_user = "postgresql-Firefly"
            mealie_user = "postgresql-Mealie"
            sonarr = "postgresql-Sonarr"
            radarr = "postgresql-Radarr"
            prowlarr = "postgresql-Prowlarr"
            litellm = "postgresql-LiteLLM"
            n8n = "postgresql-N8N"
        }
        authentik = {
            api_token = "Authentik Token"
            secret_key = "Authentik Secret Key"
            admin_credentials = "Authentik admin login"
            geo_ip = "Authentik GeoIP"
            azure_secret = "Authentik Azure Secret"

        }
        grafana = {
            api_token = "Grafana Cloud token"
        }
    }
    ip_address = {
        ingress = "10.0.49.25"
        adguard_ipv4 = "10.0.49.26/32"
        adguard_ipv6 = "fd00:10::49:26/128"
        extra_pool = "10.0.49.40-10.0.49.50"
        nas_ip = "192.168.20.3"
    }
    file_share = {
        nas_root_mount = "/volume1/k8s"
        nas_plex_root = "/volume1/Plex-Media"
        P2P_root      = "/volume2/P2P"
    }
    database = {
        backup_c2_bucket = "postgresql"
        read_write_service_name = "postgresql-cluster-postgresql-main-rw"
    }
    authentik = {
        group_admin     = "Admin"
        group_household = "Household"
        group_guests    = "Guests"
    }
}