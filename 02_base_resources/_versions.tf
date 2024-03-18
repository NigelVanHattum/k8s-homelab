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
      source = "alekc/kubectl"
      version = ">= 2.0.0, < 3.0.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = ">= 2.11.0, < 3.0.0"
    }
    argocd = {
      source = "oboukili/argocd"
      version = ">= 6.0.3, < 7.0.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = ">= 4.0.4, < 5.0.0"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = ">= 1.21.0, < 2.0.0"
    }
    authentik = {
      source = "goauthentik/authentik"
      version = ">= 2023.10.0, < 2024.0.0"
    }
  }
}