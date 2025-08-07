terraform {
  required_version = ">= 1.5.0, < 2.0.0"
  required_providers {
    onepassword = {
      source = "1Password/onepassword"
      version = ">= 2.0.0, < 3.0.0"
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
      source = "argoproj-labs/argocd"
      version = ">= 7.0.0, < 8.0.0"
    }
    authentik = {
      source = "goauthentik/authentik"
      version = ">= 2025.0.0, < 2026.0.0"
    }
    litellm = {
      source = "ncecere/litellm"
      version = ">= 0.2.6, < 1.0.0"
    }
  }
}

locals {
  # https://github.com/mealie-recipes/mealie/releases
  mealie_version = "v3.0.2"

  # https://github.com/firefly-iii/firefly-iii/releases
  # https://hub.docker.com/r/fireflyiii/core/tags
  firefly_version = "version-6"

  ### PLEX
  # https://github.com/Prowlarr/Prowlarr/releases
  # https://hub.docker.com/r/linuxserver/prowlarr/tags
  prowlarr_version = "latest"

  # https://github.com/Radarr/Radarr/releases
  # https://hub.docker.com/r/linuxserver/radarr/tags
  radarr_version = "latest"

  # https://github.com/Sonarr/Sonarr/releases
  # https://hub.docker.com/r/linuxserver/sonarr/tags
  sonarr_version = "latest"

  # https://github.com/Ombi-app/Ombi/releases
  # https://hub.docker.com/r/linuxserver/ombi/tags
  ombi_version = "latest"
  # https://github.com/haveagitgat/Tdarr/pkgs/container/tdarr
  tdarr_version = "latest"
  
}