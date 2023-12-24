variable "k8s_mediaserver_chart_version" {
  type    = string
  default = "0.9.1"
}

variable "argocd_admin_password" {
  type = string
  description = "The admin password for argocd"
  sensitive = true
}