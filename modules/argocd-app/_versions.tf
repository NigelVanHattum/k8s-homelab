terraform {
  required_version = ">= 1.8.0, < 2.0.0"
  required_providers {
    # https://registry.terraform.io/providers/argoproj-labs/argocd/latest
    argocd = {
      source  = "argoproj-labs/argocd"
      version = ">= 7.0.0, < 8.0.0"
    }
  }
}