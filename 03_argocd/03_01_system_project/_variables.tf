variable "argo_cd_version" {
  type    = string
  default = "5.46.5"
}

variable "argocd_admin_password" {
  type = string
  description = "The admin password for argocd"
  sensitive = true
}