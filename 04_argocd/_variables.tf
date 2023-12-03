variable "argo_cd_version" {
  type    = string
  default = "5.46.5"
}

variable "azure_tenant_id" {
  type    = string
  sensitive = true
}

variable "azure_client_id" {
  type    = string
  sensitive = true
}

variable "azure_client_secret" {
  type    = string
  sensitive = true
}

variable "entra_admin_group_id" {
  type    = string
  sensitive = true
}