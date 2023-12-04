terraform {
  required_version = ">= 1.5.0, < 2.0.0"
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
      version = ">= 2023.10.0, < 2024.0.0"
    }
  }
}