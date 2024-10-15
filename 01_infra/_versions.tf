terraform {
  required_version = ">= 1.8.0, < 2.0.0"
  required_providers {
    onepassword = {
      source = "1Password/onepassword"
      version = ">= 2.0.0, < 3.0.0"
    }
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc4"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.6.0"
    }
    kubectl = {
      source = "alekc/kubectl"
      version = ">= 2.0.0, < 3.0.0"
    }
  }
}