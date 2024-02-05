terraform {
  required_version = ">= 1.5.0, < 2.0.0"
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}