### 1Password
variable "onepassword_service_token" {
  type    = string
  sensitive = true
  }

#### ArgoCD
variable "entra_admin_group_id" {
  type    = string
  # sensitive = true
  default   = "TODO"
  }

### InfluxDB
variable "influxdb_secret_name" {
  type = string
  default = "influxdb-admin-user"
  }