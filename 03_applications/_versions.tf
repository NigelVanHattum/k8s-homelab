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