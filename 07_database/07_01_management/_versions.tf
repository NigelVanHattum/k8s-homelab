terraform {
  required_version = ">= 1.5.0, < 2.0.0"
  required_providers {
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = ">= 1.21.0, < 2.0.0"
    }
  }
}