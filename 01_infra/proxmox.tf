locals {
  target_node = "proxmox"
  iso_file = "talos-linux-utils.iso"
}

resource "proxmox_vm_qemu" "talos_machines" {
  for_each = var.all_vms

  name = each.key
  target_node = local.target_node

  start_at_node_boot = true
  vm_state = "running"
  qemu_os = "other"
  scsihw = "virtio-scsi-pci"
  memory = each.value.memory
  skip_ipv6 = true

  tags = "managed-by-terraform"

  cpu {
    type = "host"
    cores = each.value.cpu_cores
  }

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

  dynamic "pcis" {
    for_each = length(each.value.pcis) > 0 ? [1] : []  # Skip if no PCI configs
    content {
      # Dynamically include pci0 if "0" is in the pcis map, repeat for me pci devices as needed
      dynamic "pci0" {
        for_each = contains(keys(each.value.pcis), "0") ? [each.value.pcis["0"]] : []
        content {
          dynamic "mapping" {
            for_each = pci0.value.type == "mapping" ? [pci0.value] : []
            content {
              mapping_id     = mapping.value.mapping_id
              pcie           = mapping.value.pcie
              primary_gpu    = mapping.value.primary_gpu
              rombar         = mapping.value.rombar
              device_id      = mapping.value.device_id
              vendor_id      = mapping.value.vendor_id
              sub_device_id  = mapping.value.sub_device_id
              sub_vendor_id  = mapping.value.sub_vendor_id
            }
          }
          dynamic "raw" {
            for_each = pci0.value.type == "raw" ? [pci0.value] : []
            content {
              raw_id         = raw.value.raw_id
              pcie           = raw.value.pcie
              primary_gpu    = raw.value.primary_gpu
              rombar         = raw.value.rombar
              device_id      = raw.value.device_id
              vendor_id      = raw.value.vendor_id
              sub_device_id  = raw.value.sub_device_id
              sub_vendor_id  = raw.value.sub_vendor_id
            }
          }
        }
      }
    }
  }

  startup_shutdown {
    order            = -1 
    shutdown_timeout = -1 
    startup_delay    = -1
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