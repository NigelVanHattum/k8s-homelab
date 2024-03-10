variable "proxmox_url" {
  type = string
  description = "The API URL of the Proxmox server"
  default = "https://10.0.48.20:8006/api2/json"
}

variable "proxmox_api_key_id" {
  type = string
  description = "The id of the API key used for proxmox authentication"
  default = "Terraform@pve!feb2024"
}

variable "proxmox_api_key_secret" {
  type = string
  description = "The secret value of the API key used"
  sensitive = true
}

variable "master_vms" {
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