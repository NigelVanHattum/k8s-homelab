terraform {
  required_version = ">= 1.5.0, < 2.0.0"
  required_providers {
    onepassword = {
      source = "1Password/onepassword"
      version = ">= 1.4.1, < 2.0.0"
    }
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc1"
    }
    talos = {
      source = "siderolabs/talos"
      version = ">= 0.4.0, < 1.0.0"
    }
    kubectl = {
      source = "alekc/kubectl"
      version = ">= 2.0.0, < 3.0.0"
    }
  }
}