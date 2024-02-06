resource "proxmox_vm_qemu" "talos-controlpane" {
  name = "talos-cp-1"
  target_node = var.proxmox_target_node
  iso = "local:iso/${var.k8s_iso}"
  onboot = true
  vm_state = "running"
  qemu_os = "other"
  scsihw = "virtio-scsi-pci"
  cpu = "host"
  cores = var.k8s_master_cpu
  memory = var.k8s_master_ram

  disks {
    scsi {
      scsi0 {
        disk{
          storage = "local-lvm"
          size = 20
        }
      }
    }
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
  vm_state = "running"
  qemu_os = "other"
  scsihw = "virtio-scsi-pci"
  cpu = "host"
  cores = var.k8s_worker_cpu
  memory = var.k8s_worker_ram

  disks {
    scsi {
      scsi0 {
        disk{
          storage = "local-lvm"
          size = 20
        }
      }
    }
  }

  network {
    model = "virtio"
    bridge = "vmbr0"
    firewall = false
    macaddr = var.k8s_worker_MAC_addresses[count.index]
  }
}