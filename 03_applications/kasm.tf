# resource "kubernetes_secret" "kasm_postgres_admin" {
#   metadata {
#     name = "postgres-admin"
#     namespace = kubernetes_namespace.kasm.metadata.0.name
#   }

#   data = {
#     db_postgres_password = data.onepassword_item.database_postgresql.password   
#   }
# }

resource "kubectl_manifest" "self_signed_issuer_kasm" {
  yaml_body = templatefile("${path.module}/manifests/cert-manager/self-signed-issuer.yaml",
    {
      namespace = kubernetes_namespace.kasm.metadata.0.name
    })
  
}


# For setting up scaling via Proxmox, follow instructions here:
# https://kasm.com/docs/latest/how_to/infrastructure_components/autoscale_providers/proxmox.html
module "kasm_argo" {
  source = "../modules/argocd-app"

  app_name ="kasm"
  namespace = kubernetes_namespace.kasm.metadata.0.name
  chart   = {
    repo_url  = argocd_repository.my_homelab.repo
    repo_exists = true
    chart     = "kasm"
    version   = var.kasm_chart_version
  }

  helm_values = templatefile("helm-values/kasm.yaml",
        {
          kasm_version = "1.18.0"
          hostname     = "browse.${local.domain}"
        })
}