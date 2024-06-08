### 1Password
variable "onepassword_service_token" {
  type    = string
  sensitive = true
  }

variable "master_vms" {
  type = map(object({
    mac_address  = string
    ip_address   = string
    vm_id        = number
    cpu_cores    = optional(number, 6)
    memory       = optional(number, 8192)
    storage_size = optional(number, 32)
    storage_name = optional(string, "local-lvm")
    vlan_tag     = optional(number, -1)
  }))
}

variable "worker_vms" {
  type = map(object({
    mac_address  = string
    ip_address   = string
    vm_id        = number
    cpu_cores    = optional(number, 4)
    memory       = optional(number, 4096)
    storage_size = optional(number, 32)
    storage_name = optional(string, "local-lvm")
    vlan_tag     = optional(number, -1)
  }))
}