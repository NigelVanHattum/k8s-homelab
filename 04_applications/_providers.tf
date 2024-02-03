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
  password = data.kubernetes_secret.argocd_secret.data.password
}

provider "authentik" {
  url   = "https://authentik.nigelvanhattum.nl"
  token = data.onepassword_item.authentik_admin_token.password
}