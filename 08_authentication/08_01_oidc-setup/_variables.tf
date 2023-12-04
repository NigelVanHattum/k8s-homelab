variable "authentik_token" {
  type = string
  description = "The Authentik token"
  sensitive = true
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
