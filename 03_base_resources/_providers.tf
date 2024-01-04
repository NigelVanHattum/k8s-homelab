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
  host            = "10.0.49.25"
  port            = 5432
  username        = "postgres"
  password        = var.postgresql_admin_password
  sslmode         = "disable"
  connect_timeout = 15
}