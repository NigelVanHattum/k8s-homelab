terraform {
  required_version = ">= 1.5.0, < 2.0.0"
  required_providers {
    onepassword = {
      source = "1Password/onepassword"
      version = ">= 1.4.1, < 2.0.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.23.0, < 3.0.0"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
      version = ">= 1.14.0, < 2.0.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = ">= 2.11.0, < 3.0.0"
    }
    argocd = {
      source = "oboukili/argocd"
      version = ">= 6.0.3, < 7.0.0"
    }
    authentik = {
      source = "goauthentik/authentik"
      version = ">= 2024.0.0, < 2025.0.0"
    }
  }
}

locals {
  # https://github.com/mealie-recipes/mealie/releases
  mealie_version = "v2.2.0"

  # https://github.com/firefly-iii/firefly-iii/releases
  # https://hub.docker.com/r/fireflyiii/core/tags
  firefly_version = "version-6.1"

  ### PLEX
  # https://github.com/Prowlarr/Prowlarr/releases
  # https://hub.docker.com/r/linuxserver/prowlarr/tags
  prowlarr_version = "1.26.1"

  # https://github.com/Radarr/Radarr/releases
  # https://hub.docker.com/r/linuxserver/radarr/tags
  radarr_version = "5.15.1"

  # https://github.com/Sonarr/Sonarr/releases
  # https://hub.docker.com/r/linuxserver/sonarr/tags
  sonarr_version = "4.0.10"

  # https://github.com/Ombi-app/Ombi/releases
  # https://hub.docker.com/r/linuxserver/ombi/tags
  ombi_version = "4.44.1"
  # https://github.com/haveagitgat/Tdarr/pkgs/container/tdarr
  tdarr_version = "2.27.02"
  
}