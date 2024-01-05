variable "linkerd_chart_version" {
  type = string
  description = "linkerd chart version"
  default = "1.16.8"
}

variable "argocd_chart_version" {
  type    = string
  description = "argocd chart version"
  default = "5.52.0"
}

variable "authentik_chart_version" {
  type = string
  description = "authentik chart version"
  default = "2023.10.4"
}

variable "nfs_csi_driver_chart_version" {
  type    = string
  default = "v4.5.0"
}

variable "metallb_chart_version" {
  type = string
  description = "MetalLB version"
  default = "0.13.12"
}

variable "traefik_chart_version" {
  type = string
  description = "Traefik chart version (not traefik version)"
  default = "26.0.0"
}

variable "postgresql_chart_version" {
  type    = string
  default = "12.3.7"
}

variable "influxdb_chart_version" {
  type    = string
  default = "2.1.2"
}