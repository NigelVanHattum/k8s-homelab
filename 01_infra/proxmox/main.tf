
terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.proxmox_url
  pm_api_token_id = var.proxmox_api_key_id
  pm_api_token_secret = var.proxmox_api_key_secret
  pm_tls_insecure = var.proxmox_tls_insecure

  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
  pm_debug      = true
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}

resource "proxmox_vm_qemu" "talos-controlpane" {
  name = "talos-cp-1"
  target_node = var.proxmox_target_node
  iso = "local:iso/${var.k8s_iso}"
  onboot = true
  oncreate = true
  qemu_os = "other"
  scsihw = "virtio-scsi-pci"
  cpu = "host"
  cores = var.k8s_master_cpu
  memory = var.k8s_master_ram

  disk {
    type = "scsi"
    storage = "local-lvm"
    size = "20G"
  }

  network {
    model = "virtio"
    bridge = "vmbr0"
    firewall = false
    macaddr = var.k8s_master_MAC
  }
}

resource "proxmox_vm_qemu" "k8s-workers" {
  count = var.k8s_worker_count
  name = "talos-worker-${count.index}"
  target_node = var.proxmox_target_node
  iso = "local:iso/${var.k8s_iso}"
  onboot = true
  oncreate = true
  qemu_os = "other"
  scsihw = "virtio-scsi-pci"
  cpu = "host"
  cores = var.k8s_worker_cpu
  memory = var.k8s_worker_ram

  disk {
    type = "scsi"
    storage = "local-lvm"
    size = "20G"
  }

  network {
    model = "virtio"
    bridge = "vmbr0"
    firewall = false
    macaddr = var.k8s_worker_MAC_addresses[count.index]
  }
}