locals {
  target_node = "proxmox"
  iso_file = "talos-linux-utils.iso"
}

resource "proxmox_vm_qemu" "talos-controlpane" {
  for_each = var.master_vms

  name = each.key
  target_node = local.target_node
  # iso = "local:iso/${local.iso_file}"

  onboot = true
  vm_state = "running"
  qemu_os = "other"
  scsihw = "virtio-scsi-pci"
  cpu_type = "host"
  cores = each.value.cpu_cores
  memory = each.value.memory
  skip_ipv6 = true

  disks {
    ide {
      ide2 {
        cdrom {
          iso = "local:iso/${local.iso_file}"
        }
      }
    }
    scsi {
      scsi0 {
        disk{
          storage = each.value.storage_name
          size = each.value.storage_size
        }
      }
    }
  }

  network {
    id        = each.value.network_id
    model     = "virtio"
    bridge    = "vmbr0"
    firewall  = false
    macaddr   = each.value.mac_address
    # tag       = each.value.vlan_tag
  }
}

resource "proxmox_vm_qemu" "talos-worker" {
  for_each = var.worker_vms

  name = each.key
  target_node = local.target_node
  # iso = "local:iso/${local.iso_file}"

  onboot = true
  vm_state = "running"
  qemu_os = "other"
  scsihw = "virtio-scsi-pci"
  cpu_type = "host"
  cores = each.value.cpu_cores
  memory = each.value.memory
  skip_ipv6 = true

  disks {
    ide {
      ide2 {
        cdrom {
          iso = "local:iso/${local.iso_file}"
        }
      }
    }
    scsi {
      scsi0 {
        disk{
          storage = each.value.storage_name
          size = each.value.storage_size
        }
      }
    }
  }

  network {
    id        = each.value.network_id
    model     = "virtio"
    bridge    = "vmbr0"
    firewall  = false
    macaddr   = each.value.mac_address
    # tag       = each.value.vlan_tag
  }
}