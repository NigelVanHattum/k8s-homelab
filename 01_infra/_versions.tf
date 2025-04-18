terraform {
  required_version = ">= 1.8.0, < 2.0.0"
  required_providers {
    onepassword = {
      source = "1Password/onepassword"
      version = ">= 2.0.0, < 3.0.0"
    }
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc6"
    }
    talos = {
      source = "siderolabs/talos"
      version = ">= 0.7.0, < 0.8.0"
    }
    kubectl = {
      source = "alekc/kubectl"
      version = ">= 2.0.0, < 3.0.0"
    }
  }
}

locals {
  # https://github.com/siderolabs/talos/releases
   talos_version = "v1.9.5"
}