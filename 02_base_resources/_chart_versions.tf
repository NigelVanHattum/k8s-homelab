variable "linkerd_crd_chart_version" {
  type = string
  description = "linkerd chart version"
  default = "2024.5.3"
}

variable "linkerd_control_plane_chart_version" {
  type = string
  description = "linkerd chart version"
  default = "2024.5.3"
}

variable "argocd_chart_version" {
  type    = string
  description = "argocd chart version"
  default = "6.9.3"
}

variable "nfs_csi_driver_chart_version" {
  type    = string
  default = "v4.7.0"
}

variable "metallb_chart_version" {
  type = string
  description = "MetalLB version"
  default = "0.14.5"
}

variable "traefik_chart_version" {
  type = string
  description = "Traefik chart version (not traefik version)"
  default = "28.0.0"
}

variable "cnpg_postgres_operator_chart_version" {
  type    = string
  default = "0.21.5"
}

variable "cnpg_postgres_cluster_chart_version" {
  type    = string
  default = "0.0.9"
}

variable "influxdb_chart_version" {
  type    = string
  default = "2.1.2"
}

variable "authentik_chart_version" {
  type = string
  description = "authentik chart version"
  default = "2024.6.1"
}