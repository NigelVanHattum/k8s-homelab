locals {
    domain = "nigelvanhattum.nl"
    onepassword = {
        vault_name = "Homelab"
        azure_tenant = "Azure tenant"
        argo = {
            admin = "ArgoCD admin login"
            azure_secret = "ArgoCD Azure Secret"
        }
        traefik = {
            cloudflare_api_token = "Cloudflare DNS token"
        }
        postgresql = {
            synology_c2 = "Synology C2"
            postgres_user = "postgresql-postgres"
            authentik_user = "postgresql-Authentik"
            firefly_user = "postgresql-Firefly"
            mealie_user = "postgresql-Mealie"
            sonarr = "postgresql-Sonarr"
        }
        authentik = {
            api_token = "Authentik Token"
            secret_key = "Authentik Secret Key"
            admin_credentials = "Authentik admin login"
            geo_ip = "Authentik GeoIP"
            azure_secret = "Authentik Azure Secret"

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
    }
    database = {
        backup_c2_bucket = "postgresql-backup"
        read_write_service_name = "postgresql-cluster-rw"
    }
}