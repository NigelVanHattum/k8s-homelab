terraform {
  # https://github.com/hashicorp/terraform/releases
  required_version = ">= 1.8.0, < 2.0.0"
  required_providers {
    # https://registry.terraform.io/providers/1Password/onepassword/latest
    onepassword = {
      source  = "1Password/onepassword"
      version = ">= 3.0.0, < 4.0.0"
    }
    # https://registry.terraform.io/providers/Telmate/proxmox/latest/docs
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc07"
    }
    # https://registry.terraform.io/providers/siderolabs/talos/0.8.0
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.10.0, < 0.11.0"
    }
    # https://registry.terraform.io/providers/alekc/kubectl/latest
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.0, < 3.0.0"
    }
  }
}

locals {
  # https://github.com/siderolabs/talos/releases
  talos_version = "v1.12.2"
  # https://github.com/kubernetes/kubernetes/releases
  # https://www.talos.dev/v1.12/introduction/support-matrix/
  k8s_version = "1.35.0"
}