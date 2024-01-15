### Azure
variable "azure_tenant_id" {
  type    = string
  sensitive = true
  }

#### ArgoCD
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

### Authentik
variable "authentik_secret_key" {
  type = string
  sensitive = true
}

variable "auhtentik_email" {
  type = string
  sensitive = true
}

variable "authentik_admin_password" {
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

variable "authentik_azure_client_id" {
  type    = string
  sensitive = true
}

variable "authentik_azure_client_secret" {
  type    = string
  sensitive = true
}