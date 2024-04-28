variable "linkerd_crd_chart_version" {
  type = string
  description = "linkerd chart version"
  default = "1.8.0"
}

variable "linkerd_control_plane_chart_version" {
  type = string
  description = "linkerd chart version"
  default = "1.16.11"
}

variable "argocd_chart_version" {
  type    = string
  description = "argocd chart version"
  default = "6.7.17"
}

variable "nfs_csi_driver_chart_version" {
  type    = string
  default = "v4.6.0"
}

variable "metallb_chart_version" {
  type = string
  description = "MetalLB version"
  default = "0.14.5"
}

variable "traefik_chart_version" {
  type = string
  description = "Traefik chart version (not traefik version)"
  default = "27.0.2"
}

variable "cnpg_postgres_operator_chart_version" {
  type    = string
  default = "0.21.1"
}

variable "cnpg_postgres_cluster_chart_version" {
  type    = string
  default = "0.0.8"
}

variable "influxdb_chart_version" {
  type    = string
  default = "2.1.2"
}

variable "authentik_chart_version" {
  type = string
  description = "authentik chart version"
  default = "2024.4.1"
}