
variable "proxmox_url" {
  type = string
  description = "The API URL of the Proxmox server"
  default = "https://pve.rcomanne.nl:8006/api2/json"
}

variable "proxmox_tls_insecure" {
  type = bool
  description = "Whether to access the Proxmox API without TLS validation"
  default = true
}

variable "proxmox_api_key_id" {
  type = string
  description = "The id of the API key used for proxmox authentication"
  default = "terraform@pve!terraform-01"
}

variable "proxmox_api_key_secret" {
  type = string
  description = "The secret value of the API key used"
  sensitive = true
}

variable "proxmox_target_node" {
  type = string
  description = "The name of the Proxmox node to create the VMs on."
  default = "pve"
}

variable "k8s_iso" {
  type = string
  description = "The ISO to use for the k8s nodes"
  default = "talos-amd64.iso"
}

variable "k8s_master_cpu" {
  type = number
  description = "The number of CPU cores to allocate to the master node(s)"
  default = 2
}

variable "k8s_master_ram" {
  type = number
  description = "The amount of RAM to allocate to the master node(s)"
  default = 2048
}

variable "k8s_worker_count" {
  type = number
  description = "The number worker nodes to create"
  default = 3
}

variable "k8s_worker_cpu" {
  type = number
  description = "The number of CPU cores to allocate to the master node(s)"
  default = 3
}

variable "k8s_worker_ram" {
  type = number
  description = "The amount of RAM to allocate to the master node(s)"
  default = 9216
}