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

### Databases
variable "pgpool_customUsersSecret" {
  type = string
  default = "postgres-users"
  }
variable "postgresql_hass_password" {
  type = string
  sensitive = true
  }
variable "postgresql_hass_username" {
  type = string
  default = "homeassistant"
  }

### InfluxDB
variable "influxdb_secret_name" {
  type = string
  default = "influxdb-admin-user"
  }
variable "influxdb_admin_token" {
  type = string
  sensitive = true
  }
variable "influxdb_admin_password" {
  type = string
  sensitive = true
  }