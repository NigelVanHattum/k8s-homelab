# resource "kubernetes_secret" "kasm_postgres_admin" {
#   metadata {
#     name = "postgres-admin"
#     namespace = kubernetes_namespace.kasm.metadata.0.name
#   }

#   data = {
#     db_postgres_password = data.onepassword_item.database_postgresql.password   
#   }
# }

locals {
  # Iterate over sections and build a map: { "manager-token": "value", "service-token": "value" }
  # Assumes each section has at least one field with label="password" and takes field[0].value
  kasm_admin_secret_map = merge(
    # Dynamic map from sections (e.g., manager-token, service-token)
    { for sec in data.onepassword_item.kasm_admin.section : sec.label => sec.field[0].value },
    # Static password field
    { "admin-password" = data.onepassword_item.kasm_admin.password }
  )
  kasm_secret_map = merge(
    local.kasm_admin_secret_map,
    { "user-password" = data.onepassword_item.kasm_user.password }
  )
}

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

  # Extra addition to ignore the secret
  ignore_differences = [{
      group = "*" #v1
      kind  = "Secret"
      name  = "kasm-secrets"
      json_pointers = ["/data"]
    }]
  

  helm_values = templatefile("helm-values/kasm.yaml",
        {
          kasm_version = local.kasm_version
          hostname     = "browse.${local.domain}"
          kasm_db_secret_name = kubernetes_secret.kasm_db_credentials.metadata[0].name
        })
  
  depends_on = [ kubernetes_secret.kasm_secrets ]
}