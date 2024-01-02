variable "authentik_chart_version" {
  type = string
  description = "authentik chart version"
  default = "2023.10.5"
}

variable "argocd_admin_password" {
  type = string
  description = "The admin password for argocd"
  sensitive = true
}

variable "postgresql_password" {
  type = string
  sensitive = true
}

variable "authentik_secret_key" {
  type = string
  sensitive = true
}

variable "geoIP_accountId" {
  type = string
  sensitive = true
}

variable "geoIP_licenseKey" {
  type = string
  sensitive = true
}