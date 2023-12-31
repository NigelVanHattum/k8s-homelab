provider "kubernetes" {
  config_path    = "~/.kube/config"
}

provider "kubectl" {}

provider "helm" {
  # Configuration options
}

provider "argocd" {
  plain_text = true
  port_forward_with_namespace = "argo"
  username = "admin"
  password = var.argocd_admin_password
}