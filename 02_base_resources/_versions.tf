terraform {
  # https://github.com/hashicorp/terraform/releases
  required_version = ">= 1.8.0, < 2.0.0"
  required_providers {
    # https://registry.terraform.io/providers/1Password/onepassword/latest
    onepassword = {
      source = "1Password/onepassword"
      version = ">= 2.0.0, < 3.0.0"
    }
    # https://registry.terraform.io/providers/alekc/kubectl/latest
    kubectl = {
      source = "alekc/kubectl"
      version = ">= 2.0.0, < 3.0.0"
    }
    # https://registry.terraform.io/providers/hashicorp/helm/latest
    helm = {
      source = "hashicorp/helm"
      version = ">= 2.11.0, < 3.0.0"
    }
    # https://registry.terraform.io/providers/argoproj-labs/argocd/latest
    argocd = {
      source = "argoproj-labs/argocd"
      version = ">= 7.0.0, < 8.0.0"
    }
    # https://registry.terraform.io/providers/hashicorp/tls/latest
    tls = {
      source = "hashicorp/tls"
      version = ">= 4.0.4, < 5.0.0"
    }
    # https://registry.terraform.io/providers/cyrilgdn/postgresql/latest
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = ">= 1.21.0, < 2.0.0"
    }
    # https://registry.terraform.io/providers/goauthentik/authentik/latest
    authentik = {
      source = "goauthentik/authentik"
      version = ">= 2025.0.0, < 2026.0.0"
    }
  }
}