variable "proxmox_url" {
  type = string
  description = "The API URL of the Proxmox server"
  default = "https://10.0.48.20:8006/api2/json"
}

variable "proxmox_tls_insecure" {
  type = bool
  description = "Whether to access the Proxmox API without TLS validation"
  default = true
}

variable "proxmox_api_key_id" {
  type = string
  description = "The id of the API key used for proxmox authentication"
  default = "Terraform@pve!feb2024"
}

variable "proxmox_api_key_secret" {
  type = string
  description = "The secret value of the API key used:"
  sensitive = true
}

variable "proxmox_target_node" {
  type = string
  description = "The name of the Proxmox node to create the VMs on."
  default = "k8s-master-node"
}

variable "k8s_iso" {
  type = string
  description = "The ISO to use for the k8s nodes"
  default = "talos-metal-amd64.iso"
}

variable "k8s_master_cpu" {
  type = number
  description = "The number of CPU cores to allocate to the master node(s)"
  default = 4
}

variable "k8s_master_ram" {
  type = number
  description = "The amount of RAM to allocate to the master node(s)"
  default = 4096
}

variable "k8s_master_MAC" {
  type = string
  description = "MAC address for master node, for static IP setup"
  default = "EA:30:79:9C:FF:BE"
}

variable "k8s_worker_count" {
  type = number
  description = "The number worker nodes to create"
  default = 3
}

variable "k8s_worker_cpu" {
  type = number
  description = "The number of CPU cores to allocate to the master node(s)"
  default = 4
}

variable "k8s_worker_ram" {
  type = number
  description = "The amount of RAM to allocate to the master node(s)"
  default = 4096
}

variable "k8s_worker_MAC_addresses" {
  type = list(string)
  description = "Default MAC addresses to assign static IPs"
  default = ["2A:B9:CB:63:98:36", "EE:FF:AC:8B:57:0F", "9E:10:27:EB:00:4E"]
}