provider "onepassword" {
  service_account_token = var.onepassword_service_token
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.infra.outputs.kube_host
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.kube_cluster_ca)
  client_certificate     = base64decode(data.terraform_remote_state.infra.outputs.kube_client_cert)
  client_key             = base64decode(data.terraform_remote_state.infra.outputs.kube_client_key)
}

provider "kubectl" {
  host                   = data.terraform_remote_state.infra.outputs.kube_host
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.kube_cluster_ca)
  client_certificate     = base64decode(data.terraform_remote_state.infra.outputs.kube_client_cert)
  client_key             = base64decode(data.terraform_remote_state.infra.outputs.kube_client_key)
  load_config_file       = false
}

provider "helm" {
  repository_config_path = "${path.module}/.helm/repositories.yaml" 
  repository_cache       = "${path.module}/.helm"
  kubernetes {
    host                   = data.terraform_remote_state.infra.outputs.kube_host
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.kube_cluster_ca)
    client_certificate     = base64decode(data.terraform_remote_state.infra.outputs.kube_client_cert)
    client_key             = base64decode(data.terraform_remote_state.infra.outputs.kube_client_key)
  }
}

provider "argocd" {
  plain_text = true
  port_forward_with_namespace = "argo"
  username = "admin"
  password = random_password.argocd_admin_password.result
  kubernetes {
    host                   = data.terraform_remote_state.infra.outputs.kube_host
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.kube_cluster_ca)
    client_certificate     = base64decode(data.terraform_remote_state.infra.outputs.kube_client_cert)
    client_key             = base64decode(data.terraform_remote_state.infra.outputs.kube_client_key)
  }
}

provider "postgresql" {
  host            = "10.0.49.25"
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