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
