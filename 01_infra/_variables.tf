### 1Password
variable "onepassword_service_token" {
  type    = string
  sensitive = true
  }

variable "cluster_name" {
  type = string
  default = "talos-homelab"
}

variable "stage_talos_upgrade" {
  description = "Debug toggle to trigger updates"
  type        = bool
  default     = false
}

variable "talos_config_path" {
  description = "The path to output the Talos configuration file."
  type        = string
  default     = "~/.talos"
}

variable "kube_config_path" {
  description = "The path to output the kubeconfig file."
  type        = string
  default     = "~/.kube"
}

variable "all_vms" {
  type = map(object({
    mac_address  = string
    ip_address   = string
    vm_id        = number
    type         = optional(string, "worker")
    ai_node      = optional(bool, false)
    architecture = optional(string, "amd64")
    platform     = optional(string, "metal")
    cpu_cores    = optional(number, 6)
    memory       = optional(number, 8192)
    storage_size = optional(number, 32)
    storage_name = optional(string, "local-lvm")
    network_id   = optional(number, 7)
    vlan_tag     = optional(number, -1)
  }))
}