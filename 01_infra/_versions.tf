terraform {
  required_version = ">= 1.5.0, < 2.0.0"
  required_providers {
    onepassword = {
      source = "1Password/onepassword"
      version = ">= 2.0.0, < 3.0.0"
    }
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
    talos = {
      source = "siderolabs/talos"
      # Stuck on 0.4.0 until https://github.com/siderolabs/terraform-provider-talos/issues/168 is fixed
      version = "0.6.0-alpha.2" #"0.5.0"
    }
    kubectl = {
      source = "alekc/kubectl"
      version = ">= 2.0.0, < 3.0.0"
    }
  }
}