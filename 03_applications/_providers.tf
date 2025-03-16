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
  username = data.onepassword_item.argo_admin.username
  password = data.onepassword_item.argo_admin.password
  kubernetes {
    host                   = data.terraform_remote_state.infra.outputs.kube_host
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.kube_cluster_ca)
    client_certificate     = base64decode(data.terraform_remote_state.infra.outputs.kube_client_cert)
    client_key             = base64decode(data.terraform_remote_state.infra.outputs.kube_client_key)
  }
}

provider "authentik" {
  url   = "https://authentik.nigelvanhattum.nl"
  token = data.onepassword_item.authentik_admin_token.password
}