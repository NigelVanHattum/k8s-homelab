variable "nfs_csi_driver_version" {
  type    = string
  default = "v4.4.0"
}

variable "argocd_admin_password" {
  type = string
  description = "The admin password for argocd"
  sensitive = true
}