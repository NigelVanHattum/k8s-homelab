variable "argocd_admin_password" {
  type = string
  description = "The admin password for argocd"
  sensitive = true
}

variable "metallb_version" {
  type = string
  description = "MetalLB version"
  default = "0.13.12"
}

variable "traefik_chart_version" {
  type = string
  description = "Traefik chart version (not traefik version)"
  default = "25.0.0"
}