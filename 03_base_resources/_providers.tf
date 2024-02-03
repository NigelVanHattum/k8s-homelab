provider "onepassword" {
  service_account_token = var.onepassword_service_token
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
}

provider "kubectl" {}

provider "helm" {
  repository_config_path = "${path.module}/.helm/repositories.yaml" 
  repository_cache       = "${path.module}/.helm"
}

provider "argocd" {
  plain_text = true
  port_forward_with_namespace = "argo"
  username = "admin"
  password = random_password.argocd_admin_password.result
}

provider "postgresql" {
  host            = data.onepassword_item.database_postgresql.hostname
  port            = data.onepassword_item.database_postgresql.port
  username        = data.onepassword_item.database_postgresql.username
  password        = data.onepassword_item.database_postgresql.password
  sslmode         = "disable"
  connect_timeout = 15
}

provider "authentik" {
  url   = "https://authentik.nigelvanhattum.nl"
  token = data.onepassword_item.authentik_admin_token.password
}