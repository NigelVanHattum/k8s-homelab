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