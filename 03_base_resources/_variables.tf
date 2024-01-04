#### ArgoCD
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
  # sensitive = true
  default   = "TODO"
  }

### Networking
variable "cloudlfare_dns_api_token" {
  type = string
  description = "Token used for cloudflare DNS challenge"
  sensitive = true
  }

### Databases
variable "pgpool_customUsersSecret" {
  type = string
  default = "postgres-users"
  }
variable "postgresql_admin_password" {
  type = string
  sensitive = true
  }
variable "postgresql_authentik_password" {
  type = string
  sensitive = true
  }
variable "postgresql_authentik_username" {
  type = string
  default = "authentik"
  }


### Authentik
# variable "postgresql_password" {
#   type = string
#   sensitive = true
# }

# variable "authentik_secret_key" {
#   type = string
#   sensitive = true
# }

# variable "geoIP_accountId" {
#   type = string
#   sensitive = true
# }

# variable "geoIP_licenseKey" {
#   type = string
#   sensitive = true
# }