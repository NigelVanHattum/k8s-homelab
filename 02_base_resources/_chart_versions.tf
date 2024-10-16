variable "linkerd_chart_version" {
  type = string
  description = "linkerd chart version"
  default = "2024.9.2"
}

variable "argocd_chart_version" {
  type    = string
  description = "argocd chart version"
  default = "7.5.2"
}

variable "k8s_monitoring_chart_version" {
  type    = string
  description = "grafana monitoring"
  default = "1.5.1"
}

variable "nfs_csi_driver_chart_version" {
  type    = string
  default = "v4.9.0"
}

variable "metallb_chart_version" {
  type = string
  description = "MetalLB version"
  default = "0.14.8"
}

variable "traefik_chart_version" {
  type = string
  description = "Traefik chart version (not traefik version)"
  default = "31.0.0"
}

variable "cnpg_postgres_operator_chart_version" {
  type    = string
  default = "0.22.0"
}

variable "cnpg_postgres_cluster_chart_version" {
  type    = string
  default = "0.0.11"
}

variable "influxdb_chart_version" {
  type    = string
  default = "2.1.2"
}

variable "authentik_chart_version" {
  type = string
  description = "authentik chart version"
  default = "2024.8.1"
}