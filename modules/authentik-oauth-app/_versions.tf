terraform {
  required_version = ">= 1.8.0, < 2.0.0"
  required_providers {
    authentik = {
      source  = "goauthentik/authentik"
      version = ">= 2025.0.0, < 2026.0.0"
    }
  }
}