variable "postgresql_chart_version" {
  type    = string
  default = "12.0.5"
}

variable "argocd_admin_password" {
  type = string
  description = "The admin password for argocd"
  sensitive = true
}

variable "postgresql_admin_password" {
  type = string
  sensitive = true
}

