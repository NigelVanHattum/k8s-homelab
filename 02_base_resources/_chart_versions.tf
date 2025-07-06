# https://github.com/linkerd/linkerd2/tree/main/charts/linkerd-control-plane
# variable "linkerd_chart_version" {
#   type = string
#   description = "linkerd chart version"
#   default = "2024.11.3"
# }

# https://github.com/argoproj/argo-helm
variable "argocd_chart_version" {
  type    = string
  description = "argocd chart version"
  default = "8.1.2"
}

# https://github.com/grafana/k8s-monitoring-helm
variable "k8s_monitoring_chart_version" {
  type    = string
  description = "grafana monitoring"
  default = "3.1.0"
}

# https://github.com/kubernetes-csi/csi-driver-nfs
variable "nfs_csi_driver_chart_version" {
  type    = string
  default = "v4.11.0"
}

# https://github.com/metallb/metallb/releases
variable "metallb_chart_version" {
  type = string
  description = "MetalLB version"
  default = "0.15.2"
}

# https://github.com/traefik/traefik-helm-chart
variable "traefik_crd_chart_version" {
  type = string
  description = "Traefik CRD chart version (not traefik version)"
  default = "1.9.0"
}

variable "traefik_chart_version" {
  type = string
  description = "Traefik chart version (not traefik version)"
  default = "36.3.0"
}

# https://github.com/cloudnative-pg/charts/tree/main/charts/cloudnative-pg
variable "cnpg_postgres_operator_chart_version" {
  type    = string
  default = "0.24.0"
}

# https://github.com/cloudnative-pg/charts/tree/main/charts/cluster
variable "cnpg_postgres_cluster_chart_version" {
  type    = string
  default = "0.3.1"
}

variable "influxdb_chart_version" {
  type    = string
  default = "2.1.2"
}

# https://github.com/rm3l/helm-charts/blob/main/charts/adguard-home/README.md
variable "adguard_home_chart_version" {
  type    = string
  default = "0.20.0"
}

# https://github.com/goauthentik/helm
# https://docs.goauthentik.io/docs/releases
variable "authentik_chart_version" {
  type = string
  description = "authentik chart version"
  default = "2025.6.3"
}