module "n8n_argo" {
  source = "../modules/argocd-app"

  app_name ="n8n"
  namespace = kubernetes_namespace.n8n.metadata.0.name
  chart   = {
    repo_url  = "8gears.container-registry.com/library"
    repo_exists = false
    oci_repo = true
    chart     = "n8n"
    version   = var.n8n_chart_version
  }

  helm_values = templatefile("helm-values/n8n.yaml",
        {
          encryption_key      = data.onepassword_item.n8n_encryption_key.password
          db_host             = data.onepassword_item.database_n8n.hostname
          db_port             = data.onepassword_item.database_n8n.port
          db_name             = data.onepassword_item.database_n8n.database
          db_user             = data.onepassword_item.database_n8n.username
          db_password         = data.onepassword_item.database_n8n.password
        })
}