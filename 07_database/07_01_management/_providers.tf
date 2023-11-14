provider "postgresql" {
  # Make sure to port-forward before running :-) 
    host            = "localhost"
    port            = 5432
    username        = "postgres"
    password        = var.postgresql_admin_password
    sslmode         = "disable"
    connect_timeout = 15
}
